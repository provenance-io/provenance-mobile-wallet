import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'models/session_action.dart';
import 'models/sign_action.dart';
import 'models/tx_action.dart';
import 'models/wallet_connect_action_kind.dart';

typedef CompleterDelegate = Future<void> Function(bool accept);

class WalletConnectSessionDelegateEvents {
  WalletConnectSessionDelegateEvents();

  final _subscriptions = CompositeSubscription();

  final _sessionRequest = PublishSubject<SessionAction>(sync: true);
  final _signRequest = PublishSubject<SignAction>(sync: true);
  final _sendRequest = PublishSubject<TxAction>(sync: true);
  final _onDidError = PublishSubject<String>(sync: true);
  final _onResponse = PublishSubject<TxResult>(sync: true);
  final _onClose = PublishSubject<void>(sync: true);

  Stream<SessionAction> get sessionRequest => _sessionRequest;
  Stream<SignAction> get signRequest => _signRequest;
  Stream<TxAction> get sendRequest => _sendRequest;
  Stream<String> get onDidError => _onDidError;
  Stream<TxResult> get onResponse => _onResponse;
  Stream<void> get onClose => _onClose;

  void listen(WalletConnectSessionDelegateEvents other) {
    other.sessionRequest.listen(_sessionRequest.add).addTo(_subscriptions);
    other.signRequest.listen(_signRequest.add).addTo(_subscriptions);
    other.sendRequest.listen(_sendRequest.add).addTo(_subscriptions);
    other.onDidError.listen(_onDidError.add).addTo(_subscriptions);
    other.onResponse.listen(_onResponse.add).addTo(_subscriptions);
    other.onClose.listen(_onClose.add).addTo(_subscriptions);
  }

  Future<void> clear() async {
    await _subscriptions.clear();
  }

  Future<void> dispose() async {
    await _subscriptions.dispose();

    await Future.wait([
      _sessionRequest.close(),
      _signRequest.close(),
      _sendRequest.close(),
      _onDidError.close(),
      _onResponse.close(),
      _onClose.close()
    ]);
  }
}

class WalletConnectSessionDelegate implements WalletConnectionDelegate {
  WalletConnectSessionDelegate({
    required TransactableAccount connectAccount,
    required TransactableAccount transactAccount,
    required AccountService accountService,
    required TxQueueService txQueueService,
    required WalletConnectQueueService queueService,
    required WalletConnection connection,
  })  : _connectAccount = connectAccount,
        _transactAccount = transactAccount,
        _accountService = accountService,
        _txQueueService = txQueueService,
        _queueService = queueService,
        _connection = connection {
    _txQueueService.response.listen((e) {
      final walletConnectRequestId = e.walletConnectRequestId;
      if (walletConnectRequestId != null) {
        _connection.sendTransactionResult(walletConnectRequestId, e.response);
      }
    }).addTo(_subscriptions);
  }

  final TransactableAccount _connectAccount;
  final TransactableAccount _transactAccount;
  final AccountService _accountService;
  final TxQueueService _txQueueService;

  final WalletConnectQueueService _queueService;
  final WalletConnection _connection;

  final _subscriptions = CompositeSubscription();

  final events = WalletConnectSessionDelegateEvents();

  ///
  /// The user has decided to allow or disallow the action.
  ///
  Future<bool> complete(String requestId, bool allowed) async {
    final action = await _queueService.loadQueuedAction(
      accountId: _transactAccount.id,
      requestId: requestId,
    );
    if (action == null) {
      return false;
    }

    final wcRequestId = action.walletConnectRequestId;
    if (!allowed) {
      await _connection.reject(wcRequestId);
      await _queueService.removeRequest(
        accountId: _transactAccount.id,
        requestId: requestId,
      );
      return true;
    }

    var result = false;

    try {
      switch (action.kind) {
        case WalletConnectActionKind.session:
          result = await _completeSessionAction(action as SessionAction);
          break;
        case WalletConnectActionKind.tx:
          result = await _completeTxAction(action as TxAction);
          break;
        case WalletConnectActionKind.sign:
          result = await _completeSignAction(action as SignAction);
          break;
      }
    } catch (e) {
      logError(
        'Request failed',
        error: e,
      );

      await _connection.sendError(
        wcRequestId,
        e.toString(),
      );

      // Allow the error to be handled where the action was initiated.
      rethrow;
    }

    return result;
  }

  ///
  /// Called when the session needs approval for a session.
  /// Use this override to notify the user.
  ///
  @override
  void onApproveSession(
    int requestId,
    SessionRequestData data,
  ) async {
    final id = Uuid().v1().toString();

    await _queueService.createWalletConnectSessionGroup(
      accountId: _transactAccount.id,
      clientMeta: data.clientMeta,
    );

    final action = SessionAction(id, requestId, data);
    events._sessionRequest.add(action);

    await _queueService.addWalletApproveRequest(
      accountId: _transactAccount.id,
      action: action,
    );
  }

  ///
  /// Called when the session needs approval for a sign.
  /// Use this override to notify the user.
  ///
  @override
  void onApproveSign(
      int requestId, String description, String address, List<int> msg) async {
    final id = Uuid().v1().toString();
    log("Approve sign");

    final signAction = SignAction(
      id: id,
      walletConnectRequestId: requestId,
      message: utf8.decode(msg),
      description: description,
      address: address,
    );

    _queueService.addWalletConnectSignRequest(
      accountId: _transactAccount.id,
      signAction: signAction,
    );
  }

  ///
  /// Called when the session needs approval for a tx.
  /// Use this override to notify the user.
  ///
  @override
  void onApproveTransaction(
    int requestId,
    String description,
    String address,
    SignTransactionData signTransactionData,
  ) async {
    log("Approve trans");
    final txBody = proto.TxBody(
      messages: signTransactionData.proposedMessages
          .map((msg) => msg.toAny())
          .toList(),
    );

    final id = Uuid().v1().toString();

    GasFeeEstimate gasEstimate;
    try {
      gasEstimate = await _txQueueService.estimateGas(
        txBody: txBody,
        account: _transactAccount,
      );
    } on GrpcError catch (e) {
      events._onDidError.add(e.message ?? e.codeName);

      await _connection.sendError(requestId, e.message ?? e.codeName);

      return null;
    }

    final txAction = TxAction(
      id: id,
      walletConnectRequestId: requestId,
      description: description,
      messages: signTransactionData.proposedMessages,
      gasEstimate: gasEstimate,
    );

    _queueService.addWalletConnectTxRequest(
      accountId: _transactAccount.id,
      txAction: txAction,
    );
  }

  @override
  void onClose() {
    events._onClose.add(null);
    _queueService.removeWalletConnectSessionGroup(
      accountId: _transactAccount.id,
    );
    _subscriptions.clear();
  }

  @override
  void onError(Exception exception) {
    logError(
      'Session error',
      error: exception,
    );

    if (exception is WalletConnectException) {
      events._onDidError.add(exception.message);
    } else {
      events._onDidError.add(exception.toString());
    }
  }

  Future<bool> _completeSessionAction(SessionAction action) async {
    final privateKey = await _accountService.loadKey(
      _connectAccount.id,
      _connectAccount.coin,
    );

    SessionApprovalData sessionApproval = SessionApprovalData(
      privateKey,
      _transactAccount.publicKey,
      _transactAccount.coin.chainId,
      WalletInfo(
        _transactAccount.id,
        _transactAccount.name,
        _transactAccount.coin,
      ),
    );

    await _connection.sendApproveSession(
      action.walletConnectRequestId,
      sessionApproval,
    );

    await _queueService.removeRequest(
      accountId: _transactAccount.id,
      requestId: action.id,
    );

    return true;
  }

  Future<bool> _completeTxAction(TxAction action) async {
    final txBody = proto.TxBody(
      messages: action.messages.map((msg) => msg.toAny()).toList(),
    );

    final queuedTx = await _txQueueService.scheduleTx(
      txBody: txBody,
      account: _transactAccount,
      gasEstimate: action.gasEstimate,
      walletConnectRequestId: action.walletConnectRequestId,
    );

    switch (queuedTx.kind) {
      case QueuedTxKind.executed:
        final executedTx = queuedTx as ExecutedTx;
        final response = executedTx.result.response;

        await _connection.sendTransactionResult(
          action.walletConnectRequestId,
          response,
        );

        events._onResponse.add(
          TxResult(
            body: txBody,
            response: response,
            fee: action.gasEstimate.toProtoFee(),
          ),
        );

        _queueService.removeRequest(
          accountId: _transactAccount.id,
          requestId: action.id,
        );
        break;
      case QueuedTxKind.scheduled:
        final scheduledTx = queuedTx as ScheduledTx;
        final txId = scheduledTx.txId;
        logDebug('Scheduled tx: $txId');

        _queueService.removeRequest(
          accountId: _transactAccount.id,
          requestId: action.id,
        );
        break;
    }

    return true;
  }

  Future<bool> _completeSignAction(SignAction action) async {
    final bytes = action.message.codeUnits;

    if (_transactAccount is MultiAccount) {
      throw 'This action is not supported for multi signature accounts';
    }

    final privateKey = await _accountService.loadKey(
      _transactAccount.id,
      _transactAccount.coin,
    );
    List<int>? signedData;
    signedData = privateKey.signData(Hash.sha256(bytes))..removeLast();

    await _connection.sendSignResult(
      action.walletConnectRequestId,
      signedData,
    );

    await _queueService.removeRequest(
      accountId: _transactAccount.id,
      requestId: action.id,
    );

    return true;
  }
}
