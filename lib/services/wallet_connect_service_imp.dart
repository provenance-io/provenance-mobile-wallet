import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/proto_bank.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/model/transaction_message.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/wallet_connect_service.dart';
import 'package:rxdart/subjects.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:uuid/uuid.dart';

import '../extension/coin_helper.dart';

abstract class TransactionHandler {
  Future<GasEstimate> estimateGas(TxBody txBody, PrivateKey privateKey);

  Future<RawTxResponsePair> executeTransaction(TxBody txBody, PrivateKey privateKey);
}

class WalletConnectServiceImp
    implements WalletConnectService,
               WalletConnectionDelegate
{
  WalletConnectServiceImp(this._privateKey, this._connection, this._transactionHandler,)
  {
    _statusStream.add(WalletConnectionServiceStatus.created);
    _connection.addListener(_statusListener);
  }

  final _sendRequest = PublishSubject<SendRequest>();
  final _signRequest = PublishSubject<SignRequest>();
  final _sessionRequest = PublishSubject<RemoteClientDetails>();
  final _statusStream = PublishSubject<WalletConnectionServiceStatus>();

  final _completerLookup = <String,Completer<bool>>{};

  final WalletConnection _connection;
  final PrivateKey _privateKey;
  final TransactionHandler _transactionHandler;

  Stream<SendRequest> get sendRequest => _sendRequest.stream;

  Stream<SignRequest> get signRequest => _signRequest.stream;

  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest.stream;

  Stream<WalletConnectionServiceStatus> get status => _statusStream.stream;

  String get address => _connection.address.bridge.toString();
  
  Future<bool> disconnectSession() async {
    if(_connection.value == WalletConnectState.disconnected) {
      return true;
    }

    _completerLookup.values.forEach((completer) => completer.complete(false));
    _completerLookup.clear();

    await _connection.disconnect();
    _connection.removeListener(_statusListener);
    _statusStream.add(WalletConnectionServiceStatus.disconnected);

    return true;
  }

  Future<bool> connectWallet() async {
    await disconnectSession();

    return _connection.connect(this)
      .then((_) => true);
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    final completer = _completerLookup.remove(requestId);
    if(completer == null) {
      return false;
    }
    completer.complete(allowed);

    return true;
  }

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  }) async {
    final completer = _completerLookup.remove(requestId);
    if(completer == null) {
      return false;
    }
    completer.complete(allowed);

    return true;
  }

  Future<bool> approveSession({
    required String requestId,
    required bool allowed,
  }) async {
    final completer = _completerLookup.remove(requestId);
    if(completer == null) {
      return false;
    }
    completer.complete(allowed);

    return true;
  }

  /* WalletConnectionDelegate */

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
    if(!approved) {
      return null;
    }

    final sessionApproval = SessionApprovalData(
        _privateKey,
        _privateKey.publicKey.coin.chainId,
    );

    return sessionApproval;
  }

  @override
  Future<List<int>?> onApproveSign(String description, String address, List<int> msg,) async {
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
    if(!approved) {
      return null;
    }

    return _privateKey.defaultKey().signData(Hash.sha256(msg))..removeLast();
  }

  @override
  Future<RawTxResponsePair?> onApproveTransaction(String description, String address, GeneratedMessage proposedMessage,) async {
    if(!(proposedMessage is MsgSend)) {
      return null;
    }

    final sendCoin = proposedMessage.amount.first;

    final id = Uuid().v1().toString();
    final completer = Completer<bool>();
    _completerLookup[id] = completer;

    final sendRequest = SendRequest(
        id: id,
        description: description,
        cost: "",
        message: TransactionMessage(
          fromAddress: proposedMessage.fromAddress,
          toAddress: proposedMessage.toAddress,
          amount: sendCoin.amount,
          denom: sendCoin.denom,

        ),
    );

    _sendRequest.add(sendRequest);
    final approved = await completer.future;
    if(!approved) {
      return null;
    }

    final txBody = TxBody(
        messages: [
          proposedMessage.toAny(),
        ],
    );

    return _transactionHandler.executeTransaction(txBody, _privateKey);
  }

  @override
  void onClose() {
    _statusStream.add(WalletConnectionServiceStatus.disconnected);
  }

  @override
  void onError(Exception exception) {
    // TODO: implement onError
  }

  void _statusListener() {
    final status = _connection.value;
    if(status == WalletConnectState.connected) {
      _statusStream.add(WalletConnectionServiceStatus.connected);
    }
    else if(status == WalletConnectState.disconnected) {
      _statusStream.add(WalletConnectionServiceStatus.disconnected);
    }
    else if(status == WalletConnectState.connecting) {
      _statusStream.add(WalletConnectionServiceStatus.connecting);
    }
  }
}