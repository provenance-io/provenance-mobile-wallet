import 'dart:async';

import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_connection_service_status.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provenance_dart/wallet_connect.dart';

class WalletConnectSession {
  WalletConnectSession({
    required WalletConnection connection,
    required WalletConnectSessionDelegate delegate,
  })  : _connection = connection,
        _delegate = delegate;

  final WalletConnection _connection;
  final WalletConnectSessionDelegate _delegate;

  final _subscriptions = CompositeSubscription();

  final _sendRequest = PublishSubject<SendRequest>();
  final _signRequest = PublishSubject<SignRequest>();
  final _sessionRequest = PublishSubject<RemoteClientDetails>();
  final _status =
      BehaviorSubject.seeded(WalletConnectionServiceStatus.disconnected);
  final _address = BehaviorSubject<String?>();

  Stream<SendRequest> get sendRequest => _sendRequest.stream;
  Stream<SignRequest> get signRequest => _signRequest.stream;
  Stream<RemoteClientDetails> get sessionRequest => _sessionRequest.stream;
  ValueStream<WalletConnectionServiceStatus> get status => _status.stream;
  ValueStream<String?> get address => _address.stream;

  Future<bool> connect() async {
    var success = false;

    try {
      _connection.addListener(_statusListener);
      _delegate.sendRequest.listen(_sendRequest.add);
      _delegate.signRequest.listen(_signRequest.add);
      _delegate.sessionRequest.listen(_sessionRequest.add);

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
    _subscriptions.dispose();
    _connection.removeListener(_statusListener);
    _status.add(WalletConnectionServiceStatus.disconnected);
    _address.value = null;

    await _connection.disconnect();

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
    required String requestId,
    required bool allowed,
  }) async {
    return _delegate.complete(requestId, allowed);
  }

  void _statusListener() {
    final status = _connection.value;
    if (status == WalletConnectState.connected) {
      _status.add(WalletConnectionServiceStatus.connected);
      _address.value = _connection.address.bridge.toString();
    } else if (status == WalletConnectState.disconnected) {
      _status.add(WalletConnectionServiceStatus.disconnected);
    } else if (status == WalletConnectState.connecting) {
      _status.add(WalletConnectionServiceStatus.connecting);
    }
  }
}
