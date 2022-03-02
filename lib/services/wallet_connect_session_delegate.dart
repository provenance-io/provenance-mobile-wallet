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
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

typedef CompleterDelegate = Future<void> Function(bool accept);

class WalletConnectSessionDelegate implements WalletConnectionDelegate {
  WalletConnectSessionDelegate({
    required PrivateKey privateKey,
    required TransactionHandler transactionHandler,
  })  : _privateKey = privateKey,
        _transactionHandler = transactionHandler;

  final PrivateKey _privateKey;
  final TransactionHandler _transactionHandler;

  final _completerLookup = <String, CompleterDelegate>{};
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

    completer(allowed);

    return true;
  }

  @override
  void onApproveSession(
    ClientMeta clientMeta,
    AcceptCallback<SessionApprovalData?> callback,
  ) async {
    final id = Uuid().v1().toString();

    _completerLookup[id] = (bool approve) {
      SessionApprovalData? sessionApproval;
      if (approve) {
        sessionApproval = SessionApprovalData(
          _privateKey,
          _privateKey.publicKey.coin.chainId,
        );
      }

      return callback(sessionApproval);
    };

    final remoteClientData = RemoteClientDetails(
      id,
      clientMeta.description,
      clientMeta.url,
      clientMeta.name,
      clientMeta.icons.toList(),
    );

    _sessionRequest.add(remoteClientData);
  }

  @override
  void onApproveSign(
    String description,
    String address,
    List<int> msg,
    AcceptCallback<List<int>?> callback,
  ) async {
    final id = Uuid().v1().toString();

    _completerLookup[id] = (bool accept) {
      List<int>? signedData;
      if (accept) {
        signedData = _privateKey.defaultKey().signData(Hash.sha256(msg))
          ..removeLast();
      }

      return callback(signedData);
    };

    final signRequest = SignRequest(
      id: id,
      message: utf8.decode(msg),
      description: description,
      address: address,
    );

    _signRequest.add(signRequest);
  }

  @override
  void onApproveTransaction(
    String description,
    String address,
    List<GeneratedMessage> proposedMessages,
    AcceptCallback<RawTxResponsePair?> callback,
  ) async {
    final proposedMessage = proposedMessages.first;

    final messageType = proposedMessage.runtimeType;
    final messageName = proposedMessage.info_.qualifiedMessageName;

    if (!_supportedMessges.contains(messageType)) {
      _onDidError.add(Strings.transactionErrorUnsupportedMessage(messageName));

      return callback(null);
    }

    final txBody = TxBody(
      messages: proposedMessages.map((msg) => msg.toAny()).toList(),
    );

    final id = Uuid().v1().toString();

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
      messages: proposedMessages,
      gasEstimate: gasEstimate,
    );

    _completerLookup[id] = (bool approve) async {
      RawTxResponsePair? response;

      if (approve) {
        response =
            await _transactionHandler.executeTransaction(txBody, _privateKey);

        final txResponse = response.txResponse;

        _onResponse.add(
          WalletConnectTxResponse(
            code: txResponse.code,
            requestId: sendRequest.id,
            message: txResponse.rawLog,
            gasWanted: txResponse.gasWanted.toInt(),
            gasUsed: txResponse.gasUsed.toInt(),
            height: txResponse.height.toInt(),
            txHash: txResponse.txhash,
            fees: gasEstimate!.fees,
            codespace: txResponse.codespace,
          ),
        );
      }

      callback(response);
    };

    _sendRequest.add(sendRequest);
  }

  @override
  void onClose() {
    _sessionRequest.close();
    _signRequest.close();
    _sendRequest.close();
    _onDidError.close();
    _onResponse.close();

    for (var completer in _completerLookup.values) {
      completer(false);
    }

    _completerLookup.clear();
  }

  @override
  void onError(Exception exception) {
    logError(exception);
    _onDidError.add(exception.toString());
  }
}
