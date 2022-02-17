import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/extension/coin_helper.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/transaction_handler.dart';
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

  final _sessionRequest = PublishSubject<RemoteClientDetails>();
  final _signRequest = PublishSubject<SignRequest>();
  final _sendRequest = PublishSubject<SendRequest>();

  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest;
  Stream<SignRequest> get signRequest => _signRequest;
  Stream<SendRequest> get sendRequest => _sendRequest;

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
    if (!(proposedMessage is MsgSend)) {
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

    final gasEstimate =
        await _transactionHandler.estimateGas(txBody, _privateKey);

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

    return response;
  }

  @override
  void onClose() {
    _sessionRequest.close();
    _signRequest.close();
    _sendRequest.close();

    _completerLookup.values.forEach((completer) => completer.complete(false));
    _completerLookup.clear();
  }

  @override
  void onError(Exception exception) {
    logError(exception);
  }
}
