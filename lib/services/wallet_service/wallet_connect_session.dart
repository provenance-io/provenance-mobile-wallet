import 'dart:async';

import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/services/models/wallet_connect_tx_response.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class WalletConnectSessionEvents {
  final _subscriptions = CompositeSubscription();

  final _state = BehaviorSubject.seeded(
    WalletConnectSessionState.disconnected(),
    sync: true,
  );
  final _error = PublishSubject<String>(sync: true);
  final _response = PublishSubject<WalletConnectTxResponse>(sync: true);

  ValueStream<WalletConnectSessionState> get state => _state;
  Stream<String> get error => _error;
  Stream<WalletConnectTxResponse> get response => _response;

  void listen(WalletConnectSessionEvents other) {
    other.state.listen(_state.add).addTo(_subscriptions);
    other.error.listen(_error.add).addTo(_subscriptions);
    other.response.listen(_response.add).addTo(_subscriptions);
  }

  void clear() {
    _subscriptions.clear();
  }

  void dispose() {
    _subscriptions.dispose();
    _state.close();
    _error.close();
    _response.close();
  }
}

class WalletConnectSession {
  WalletConnectSession({
    required WalletConnection connection,
    required WalletConnectSessionDelegate delegate,
  })  : _connection = connection,
        _delegate = delegate,
        sessionEvents = WalletConnectSessionEvents(),
        delegateEvents = WalletConnectSessionDelegateEvents()
          ..listen(delegate.events);

  final WalletConnection _connection;
  final WalletConnectSessionDelegate _delegate;

  final WalletConnectSessionEvents sessionEvents;
  final WalletConnectSessionDelegateEvents delegateEvents;

  Future<bool> connect() async {
    var success = false;

    try {
      _connection.addListener(_statusListener);

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
    _disconnect();

    if (_connection.value != WalletConnectState.disconnected) {
      await _connection.disconnect();
    }

    return true;
  }

  Future<void> dispose() async {
    delegateEvents.dispose();
    sessionEvents.dispose();

    await disconnect();
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
    final success = await _delegate.complete(details.id, allowed);
    if (success) {
      sessionEvents._state.value = WalletConnectSessionState.connected(details);
    }

    return success;
  }

  void _disconnect() {
    _connection.removeListener(_statusListener);
    sessionEvents._state.value = WalletConnectSessionState.disconnected();
  }

  void _statusListener() {
    final status = _connection.value;
    logDebug('Wallet connect status: ${_connection.value}');

    // In WalletConnectState.connected state, the session is not yet approved,
    // so the session is still connecting.
    if (status == WalletConnectState.disconnected) {
      _disconnect();
    } else if (status == WalletConnectState.connecting) {
      sessionEvents._state.value = WalletConnectSessionState.connecting();
    }
  }
}
