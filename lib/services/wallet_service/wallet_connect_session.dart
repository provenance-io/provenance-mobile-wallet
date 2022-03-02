import 'dart:async';

import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connection_service_status.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class WalletConnectSession {
  WalletConnectSession({
    required WalletConnection connection,
    required WalletConnectSessionDelegate delegate,
  })  : _connection = connection,
        _delegate = delegate;

  final WalletConnection _connection;
  final WalletConnectSessionDelegate _delegate;

  final _subscriptions = CompositeSubscription();

  final _sendRequest = PublishSubject<SendRequest>(sync: true);
  final _signRequest = PublishSubject<SignRequest>(sync: true);
  final _sessionRequest = PublishSubject<RemoteClientDetails>(sync: true);
  final _clientDetails = BehaviorSubject<RemoteClientDetails?>.seeded(
    null,
    sync: true,
  );
  final _status = BehaviorSubject.seeded(
    WalletConnectionServiceStatus.disconnected,
    sync: true,
  );
  final _address = BehaviorSubject<String?>(sync: true);
  final _error = PublishSubject<String>(sync: true);
  final _response = PublishSubject<WalletConnectTxResponse>(sync: true);

  Stream<SendRequest> get sendRequest => _sendRequest;
  Stream<SignRequest> get signRequest => _signRequest;
  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest;
  ValueStream<RemoteClientDetails?> get clientDetails => _clientDetails;
  ValueStream<WalletConnectionServiceStatus> get status => _status;
  ValueStream<String?> get address => _address;
  Stream<String> get error => _error;
  Stream<WalletConnectTxResponse> get response => _response;

  Future<bool> connect() async {
    var success = false;

    try {
      _connection.addListener(_statusListener);
      _delegate.sendRequest.listen(_sendRequest.add).addTo(_subscriptions);
      _delegate.signRequest.listen(_signRequest.add).addTo(_subscriptions);
      _delegate.sessionRequest
          .listen(_sessionRequest.add)
          .addTo(_subscriptions);
      _delegate.onDidError.listen(_error.add).addTo(_subscriptions);
      _delegate.onResponse.listen(_response.add).addTo(_subscriptions);

      await _connection.connect(_delegate);

      success = true;
    } on Exception catch (e) {
      logStatic(
        WalletConnectSession,
        Level.error,
        'Failed to connect: $e',
      );
    }

    return success;
  }

  Future<bool> disconnect() async {
    _subscriptions.clear();
    _connection.removeListener(_statusListener);
    _status.add(WalletConnectionServiceStatus.disconnected);
    _address.value = null;
    _clientDetails.value = null;

    if (_connection.value != WalletConnectState.disconnected) {
      await _connection.disconnect();
    }

    return true;
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return _delegate.complete(requestId, allowed);
  }

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  }) async {
    return _delegate.complete(requestId, allowed);
  }

  Future<bool> approveSession({
    required RemoteClientDetails details,
    required bool allowed,
  }) async {
    final success = _delegate.complete(details.id, allowed);
    if (success) {
      _clientDetails.value = details;
    }

    return success;
  }

  void _statusListener() {
    final status = _connection.value;
    logDebug('Wallet connect status: ${_connection.value}');

    if (status == WalletConnectState.connected) {
      _status.add(WalletConnectionServiceStatus.connected);
      _address.value = _connection.address.bridge.toString();
    } else if (status == WalletConnectState.disconnected) {
      _status.add(WalletConnectionServiceStatus.disconnected);
      _address.value = null;
      _clientDetails.value = null;
    } else if (status == WalletConnectState.connecting) {
      _status.add(WalletConnectionServiceStatus.connecting);
    }
  }
}
