import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

typedef CompleterDelegate = Future<void> Function(bool accept);

class WalletConnectSessionDelegateEvents {
  WalletConnectSessionDelegateEvents();

  final _subscriptions = CompositeSubscription();

  final _sessionRequest =
      PublishSubject<WalletConnectSessionRequestData>(sync: true);
  final _signRequest = PublishSubject<SignRequest>(sync: true);
  final _sendRequest = PublishSubject<SendRequest>(sync: true);
  final _onDidError = PublishSubject<String>(sync: true);
  final _onResponse = PublishSubject<WalletConnectTxResponse>(sync: true);
  final _onClose = PublishSubject<void>(sync: true);

  Stream<WalletConnectSessionRequestData> get sessionRequest => _sessionRequest;
  Stream<SignRequest> get signRequest => _signRequest;
  Stream<SendRequest> get sendRequest => _sendRequest;
  Stream<String> get onDidError => _onDidError;
  Stream<WalletConnectTxResponse> get onResponse => _onResponse;
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
  WalletConnectSessionDelegate(
      {required PrivateKey privateKey,
      required WalletInfo walletInfo,
      required TransactionHandler transactionHandler,
      required WalletConnectQueueService queueService,
      required WalletConnectAddress address,
      required WalletConnection connection})
      : _privateKey = privateKey,
        _transactionHandler = transactionHandler,
        _walletInfo = walletInfo,
        _queueService = queueService,
        _address = address,
        _connection = connection;

  final PrivateKey _privateKey;
  final TransactionHandler _transactionHandler;
  final WalletInfo _walletInfo;
  final WalletConnectQueueService _queueService;
  final WalletConnectAddress _address;
  final WalletConnection _connection;

  final events = WalletConnectSessionDelegateEvents();

  Future<bool> complete(String requestId, bool allowed) async {
    final action = await _queueService.loadQueuedAction(_address, requestId);
    if (action == null) {
      return false;
    }

    final wcRequestId = action.requestId;
    if (!allowed) {
      await _connection.reject(wcRequestId);
      return true;
    }

    if (action is WalletConnectSessionRequestData) {
      final chainId = ChainId.forCoin(_privateKey.publicKey.coin);

      SessionApprovalData sessionApproval = SessionApprovalData(
        _privateKey,
        chainId,
        _walletInfo,
      );

      await _connection.sendApproveSession(wcRequestId, sessionApproval);

      await _queueService.removeRequest(_address, action.id);
      return true;
    } else if (action is SignRequest) {
      final bytes = action.message.codeUnits;
      List<int>? signedData;
      signedData = _privateKey.defaultKey().signData(Hash.sha256(bytes))
        ..removeLast();

      await _connection.sendSignResult(wcRequestId, signedData);
      await _queueService.removeRequest(_address, action.id);
    } else if (action is SendRequest) {
      final txBody = proto.TxBody(
        messages: action.messages.map((msg) => msg.toAny()).toList(),
      );

      proto.RawTxResponsePair response =
          await _transactionHandler.executeTransaction(
        txBody,
        _privateKey,
        action.gasEstimate,
      );

      final txResponse = response.txResponse;

      await _connection.sendTransactionResult(wcRequestId, response);

      events._onResponse.add(
        WalletConnectTxResponse(
          code: txResponse.code,
          requestId: action.requestId.toString(),
          message: txResponse.rawLog,
          gasWanted: txResponse.gasWanted.toInt(),
          gasUsed: txResponse.gasUsed.toInt(),
          height: txResponse.height.toInt(),
          txHash: txResponse.txhash,
          fees: action.gasEstimate.feeCalculated,
          codespace: txResponse.codespace,
        ),
      );

      _queueService.removeRequest(_address, action.id);
    }
    return false;
  }

  @override
  void onApproveSession(
    int requestId,
    SessionRequestData data,
  ) async {
    final id = Uuid().v1().toString();

    await _queueService.createWalletConnectSessionGroup(
        _address, _privateKey.defaultKey().publicKey.address, data.clientMeta);

    final details = WalletConnectSessionRequestData(id, requestId, data);
    events._sessionRequest.add(details);
    await _queueService.addWalletApproveRequest(_address, details);
  }

  @override
  void onApproveSign(
      int requestId, String description, String address, List<int> msg) async {
    final id = Uuid().v1().toString();
    log("Approve sign");

    final signRequest = SignRequest(
      id: id,
      requestId: requestId,
      message: utf8.decode(msg),
      description: description,
      address: address,
    );

    _queueService.addWalletConnectSignRequest(_address, signRequest);
  }

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
      gasEstimate = await _transactionHandler.estimateGas(
        txBody,
        _privateKey.defaultKey().publicKey.address,
      );

      if (signTransactionData.gasEstimate != null) {
        gasEstimate = gasEstimate.copyWithBaseFee(
          int.parse(signTransactionData.gasEstimate!.amount),
        );
      }
    } on GrpcError catch (e) {
      events._onDidError.add(e.message ?? e.codeName);

      return null;
    }

    final sendRequest = SendRequest(
      id: id,
      requestId: requestId,
      description: description,
      messages: signTransactionData.proposedMessages,
      gasEstimate: gasEstimate,
    );

    _queueService.addWalletConnectSendRequest(_address, sendRequest);
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
}
