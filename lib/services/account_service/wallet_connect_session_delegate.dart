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

  void clear() {
    _subscriptions.clear();
  }

  void dispose() {
    _subscriptions.dispose();

    _sessionRequest.close();
    _signRequest.close();
    _sendRequest.close();
    _onDidError.close();
    _onResponse.close();
    _onClose.close();
  }
}

class WalletConnectSessionDelegate implements WalletConnectionDelegate {
  WalletConnectSessionDelegate({
    required PrivateKey privateKey,
    required WalletInfo walletInfo,
    required TransactionHandler transactionHandler,
  })  : _privateKey = privateKey,
        _transactionHandler = transactionHandler,
        _walletInfo = walletInfo;

  final PrivateKey _privateKey;
  final TransactionHandler _transactionHandler;
  final WalletInfo _walletInfo;

  final _completerLookup = <String, CompleterDelegate>{};

  final events = WalletConnectSessionDelegateEvents();

  Future<bool> complete(String requestId, bool allowed) {
    final completer = _completerLookup.remove(requestId);
    if (completer == null) {
      return Future.value(false);
    }

    return completer(allowed).then((_) => true);
  }

  @override
  void onApproveSession(
    SessionRequestData data,
    AcceptCallback<SessionApprovalData?> callback,
  ) async {
    final id = Uuid().v1().toString();

    _completerLookup[id] = (bool approve) {
      SessionApprovalData? sessionApproval;
      final chainId = ChainId.forCoin(_privateKey.publicKey.coin);
      if (approve) {
        sessionApproval = SessionApprovalData(
          _privateKey,
          chainId,
          _walletInfo,
        );
      }

      return callback(sessionApproval, null);
    };

    final details = WalletConnectSessionRequestData(id, data);

    events._sessionRequest.add(details);
  }

  @override
  void onApproveSign(
    String description,
    String address,
    List<int> msg,
    AcceptCallback<List<int>?> callback,
  ) async {
    final id = Uuid().v1().toString();
    log("Approve sign");

    _completerLookup[id] = (bool accept) {
      List<int>? signedData;
      if (accept) {
        signedData = _privateKey.defaultKey().signData(Hash.sha256(msg))
          ..removeLast();
      }

      return callback(signedData, null);
    };

    final signRequest = SignRequest(
      id: id,
      message: utf8.decode(msg),
      description: description,
      address: address,
    );

    events._signRequest.add(signRequest);
  }

  @override
  void onApproveTransaction(
    String description,
    String address,
    SignTransactionData signTransactionData,
    AcceptCallback<proto.RawTxResponsePair?> callback,
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
        _privateKey.defaultKey().publicKey,
      );

      if (signTransactionData.gasEstimate != null) {
        gasEstimate = gasEstimate.copyWithBaseFee(
          int.parse(signTransactionData.gasEstimate!.amount),
        );
      }
    } on GrpcError catch (e) {
      events._onDidError.add(e.message ?? e.codeName);
      callback(null, e.message);

      return null;
    }

    final sendRequest = SendRequest(
      id: id,
      description: description,
      messages: signTransactionData.proposedMessages,
      gasEstimate: gasEstimate,
    );

    _completerLookup[id] = (bool approve) async {
      proto.RawTxResponsePair? response;

      if (approve) {
        response = await _transactionHandler.executeTransaction(
          txBody,
          _privateKey,
          gasEstimate,
        );

        final txResponse = response.txResponse;

        events._onResponse.add(
          WalletConnectTxResponse(
            code: txResponse.code,
            requestId: sendRequest.id,
            message: txResponse.rawLog,
            gasWanted: txResponse.gasWanted.toInt(),
            gasUsed: txResponse.gasUsed.toInt(),
            height: txResponse.height.toInt(),
            txHash: txResponse.txhash,
            fees: gasEstimate.feeCalculated,
            codespace: txResponse.codespace,
          ),
        );
      }

      return callback(response, null);
    };

    events._sendRequest.add(sendRequest);
  }

  @override
  void onClose() {
    for (var completer in _completerLookup.values) {
      completer(false);
    }

    _completerLookup.clear();
    events._onClose.add(null);
  }

  @override
  void onError(Exception exception) {
    logError(exception);

    if (exception is WalletConnectException) {
      events._onDidError.add(exception.message);
    } else {
      events._onDidError.add(exception.toString());
    }
  }
}
