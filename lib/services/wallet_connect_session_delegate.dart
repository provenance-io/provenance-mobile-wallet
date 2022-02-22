import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/proto_marker.dart';
import 'package:provenance_dart/proto_staking.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/coin_helper.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:uuid/uuid.dart';

class WalletConnectSessionDelegate implements WalletConnectionDelegate {
  WalletConnectSessionDelegate({
    required PrivateKey privateKey,
    required TransactionHandler transactionHandler,
  })  : _privateKey = privateKey,
        _transactionHandler = transactionHandler;

  final PrivateKey _privateKey;
  final TransactionHandler _transactionHandler;

  final _completerLookup = <String, Completer<bool>>{};
  static const _supportedMessges = {
    MsgActivateRequest,
    MsgAddMarkerRequest,
    MsgCancelRequest,
    MsgDelegate,
    MsgSend,
  };

  final _sessionRequest = PublishSubject<RemoteClientDetails>(sync: true);
  final _signRequest = PublishSubject<SignRequest>(sync: true);
  final _sendRequest = PublishSubject<SendRequest>(sync: true);
  final _onDidError = PublishSubject<String>(sync: true);
  final _onResponse = PublishSubject<WalletConnectTxResponse>(sync: true);

  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest;
  Stream<SignRequest> get signRequest => _signRequest;
  Stream<SendRequest> get sendRequest => _sendRequest;
  Stream<String> get onDidError => _onDidError;
  Stream<WalletConnectTxResponse> get onResponse => _onResponse;

  bool complete(String requestId, bool allowed) {
    final completer = _completerLookup.remove(requestId);
    if (completer == null) {
      return false;
    }

    completer.complete(allowed);

    return true;
  }

  @override
  Future<SessionApprovalData?> onApproveSession(ClientMeta clientMeta) async {
    final id = Uuid().v1().toString();
    final completer = Completer<bool>();
    _completerLookup[id] = completer;

    final remoteClientData = RemoteClientDetails(
      id,
      clientMeta.description,
      clientMeta.url,
      clientMeta.name,
      clientMeta.icons.toList(),
    );

    _sessionRequest.add(remoteClientData);

    final approved = await completer.future;
    if (!approved) {
      return null;
    }

    final sessionApproval = SessionApprovalData(
      _privateKey,
      _privateKey.publicKey.coin.chainId,
    );

    return sessionApproval;
  }

  @override
  Future<List<int>?> onApproveSign(
    String description,
    String address,
    List<int> msg,
  ) async {
    final id = Uuid().v1().toString();
    final completer = Completer<bool>();
    _completerLookup[id] = completer;

    final signRequest = SignRequest(
      id: id,
      message: utf8.decode(msg),
      description: description,
      cost: "",
    );

    _signRequest.add(signRequest);

    final approved = await completer.future;
    if (!approved) {
      return null;
    }

    return _privateKey.defaultKey().signData(Hash.sha256(msg))..removeLast();
  }

  @override
  Future<RawTxResponsePair?> onApproveTransaction(
    String description,
    String address,
    GeneratedMessage proposedMessage,
  ) async {
    final messageType = proposedMessage.runtimeType;
    final messageName = proposedMessage.info_.qualifiedMessageName;
    if (!_supportedMessges.contains(messageType)) {
      _onDidError.add(Strings.transactionErrorUnsupportedMessage(messageName));

      return null;
    }

    final id = Uuid().v1().toString();
    final completer = Completer<bool>();
    _completerLookup[id] = completer;

    final txBody = TxBody(
      messages: [
        proposedMessage.toAny(),
      ],
    );

    GasEstimate? gasEstimate;
    try {
      gasEstimate = await _transactionHandler.estimateGas(txBody, _privateKey);
    } on GrpcError catch (e) {
      _onDidError.add(e.message ?? e.codeName);
    }

    if (gasEstimate == null) {
      return null;
    }

    final sendRequest = SendRequest(
      id: id,
      description: description,
      message: proposedMessage,
      gasEstimate: gasEstimate,
    );

    _sendRequest.add(sendRequest);

    final approved = await completer.future;
    if (!approved) {
      return null;
    }

    final response =
        await _transactionHandler.executeTransaction(txBody, _privateKey);

    final txResponse = response.txResponse;
    _onResponse.add(
      WalletConnectTxResponse(
        code: txResponse.code,
        message: txResponse.rawLog,
      ),
    );

    return response;
  }

  @override
  void onClose() {
    _sessionRequest.close();
    _signRequest.close();
    _sendRequest.close();
    _onDidError.close();
    _onResponse.close();

    _completerLookup.values.forEach((completer) => completer.complete(false));
    _completerLookup.clear();
  }

  @override
  void onError(Exception exception) {
    logError(exception);
    _onDidError.add(exception.toString());
  }
}
