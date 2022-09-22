import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/service_tx_response.dart';
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
  final _onResponse = PublishSubject<ServiceTxResponse>(sync: true);
  final _onClose = PublishSubject<void>(sync: true);

  Stream<SessionAction> get sessionRequest => _sessionRequest;
  Stream<SignAction> get signRequest => _signRequest;
  Stream<TxAction> get sendRequest => _sendRequest;
  Stream<String> get onDidError => _onDidError;
  Stream<ServiceTxResponse> get onResponse => _onResponse;
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
    required WalletConnectAddress address,
    required WalletConnection connection,
  })  : _connectAccount = connectAccount,
        _transactAccount = transactAccount,
        _accountService = accountService,
        _txQueueService = txQueueService,
        _queueService = queueService,
        _address = address,
        _connection = connection;

  final TransactableAccount _connectAccount;
  final TransactableAccount _transactAccount;
  final AccountService _accountService;
  final TxQueueService _txQueueService;

  final WalletConnectQueueService _queueService;
  final WalletConnectAddress _address;
  final WalletConnection _connection;

  final events = WalletConnectSessionDelegateEvents();

  ///
  /// The user has decided to allow or disallow the action.
  ///
  Future<bool> complete(String requestId, bool allowed) async {
    final action = await _queueService.loadQueuedAction(_address, requestId);
    if (action == null) {
      return false;
    }

    final wcRequestId = action.walletConnectId;
    if (!allowed) {
      await _connection.reject(wcRequestId);
      return true;
    }

    bool result;

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
        _address, _transactAccount.publicKey.address, data.clientMeta);

    final details = SessionAction(id, requestId, data);
    events._sessionRequest.add(details);
    await _queueService.addWalletApproveRequest(_address, details);
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
      walletConnectId: requestId,
      message: utf8.decode(msg),
      description: description,
      address: address,
    );

    _queueService.addWalletConnectSignRequest(_address, signAction);
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

    AccountGasEstimate gasEstimate;
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
      walletConnectId: requestId,
      description: description,
      messages: signTransactionData.proposedMessages,
      gasEstimate: gasEstimate,
    );

    _queueService.addWalletConnectTxRequest(_address, txAction);
  }

  @override
  void onClose() {
    events._onClose.add(null);
    _queueService.removeWalletConnectSessionGroup(_address);
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
    final chainId = ChainId.forCoin(_transactAccount.coin);

    final privateKey = await _accountService.loadKey(_connectAccount.id);

    SessionApprovalData sessionApproval = SessionApprovalData(
      privateKey!,
      _transactAccount.publicKey,
      chainId,
      WalletInfo(
        _transactAccount.id,
        _transactAccount.name,
        _transactAccount.coin,
      ),
    );

    await _connection.sendApproveSession(
      action.walletConnectId,
      sessionApproval,
    );

    await _queueService.removeRequest(
      _address,
      action.id,
    );

    return true;
  }

  Future<bool> _completeTxAction(TxAction action) async {
    final txBody = proto.TxBody(
      messages: action.messages.map((msg) => msg.toAny()).toList(),
    );

    final scheduledTx = await _txQueueService.scheduleTx(
      txBody: txBody,
      account: _transactAccount,
      gasEstimate: action.gasEstimate,
    );

    final result = scheduledTx.result;
    if (result != null) {
      final response = result.response;
      final txResponse = response.txResponse;

      await _connection.sendTransactionResult(
        action.walletConnectId,
        response,
      );

      events._onResponse.add(
        ServiceTxResponse(
          code: txResponse.code,
          message: txResponse.rawLog,
          gasWanted: txResponse.gasWanted.toInt(),
          gasUsed: txResponse.gasUsed.toInt(),
          height: txResponse.height.toInt(),
          txHash: txResponse.txhash,
          fees: action.gasEstimate.totalFees,
          codespace: txResponse.codespace,
        ),
      );
    }

    final txId = scheduledTx.txId;
    if (txId != null) {
      logDebug('Scheduled tx: $txId');
    }

    _queueService.removeRequest(_address, action.id);

    return true;
  }

  Future<bool> _completeSignAction(SignAction action) async {
    final bytes = action.message.codeUnits;

    final privateKey = await _accountService.loadKey(_transactAccount.id);
    List<int>? signedData;
    signedData = privateKey!.defaultKey().signData(Hash.sha256(bytes))
      ..removeLast();

    await _connection.sendSignResult(
      action.walletConnectId,
      signedData,
    );

    await _queueService.removeRequest(
      _address,
      action.id,
    );

    return true;
  }
}
