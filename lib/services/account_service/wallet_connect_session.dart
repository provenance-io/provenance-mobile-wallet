import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class WalletConnectSessionEvents {
  final _subscriptions = CompositeSubscription();

  final _state = BehaviorSubject.seeded(
    WalletConnectSessionState.disconnected(),
    sync: true,
  );
  final _error = PublishSubject<String>(sync: true);

  ValueStream<WalletConnectSessionState> get state => _state;
  Stream<String> get error => _error;

  void listen(WalletConnectSessionEvents other) {
    other.state.listen(_state.add).addTo(_subscriptions);
    other.error.listen(_error.add).addTo(_subscriptions);
  }

  Future<void> clear() async {
    await _subscriptions.clear();
  }

  Future<void> dispose() async {
    await _subscriptions.dispose();
    await Future.wait([_state.close(), _error.close()]);
  }
}

class WalletConnectSessionCapturingDelegate
    implements WalletConnectionDelegate {
  WalletConnectSessionCapturingDelegate(this.session, this.childDelegte);

  final WalletConnectionDelegate childDelegte;
  final WalletConnectSession session;

  @override
  void onApproveSession(int requestId, SessionRequestData data) {
    session._startSession(data.peerId, data.remotePeerId, data.clientMeta);
    childDelegte.onApproveSession(requestId, data);
  }

  @override
  void onApproveSign(
      int requestId, String description, String address, List<int> msg) {
    childDelegte.onApproveSign(requestId, description, address, msg);
  }

  @override
  void onApproveTransaction(int requestId, String description, String address,
      SignTransactionData signTransactionData) {
    childDelegte.onApproveTransaction(
        requestId, description, address, signTransactionData);
  }

  @override
  void onClose() {
    childDelegte.onClose();
  }

  @override
  void onError(Exception exception) {
    childDelegte.onError(exception);
  }
}

class WalletConnectSession {
  WalletConnectSession(
      {required this.accountId,
      required this.coin,
      required WalletConnection connection,
      required WalletConnectSessionDelegate delegate,
      required RemoteNotificationService remoteNotificationService,
      required VoidCallback onSessionClosedRemotelyDelegate})
      : _connection = connection,
        _remoteNotificationService = remoteNotificationService,
        _delegate = delegate,
        sessionEvents = WalletConnectSessionEvents(),
        delegateEvents = WalletConnectSessionDelegateEvents()
          ..listen(delegate.events),
        onSessionClosedRemotely = onSessionClosedRemotelyDelegate;

  static const inactivityTimeout =
      Duration(minutes: 1); // Duration(minutes: 30);
  Timer? _inactivityTimer;

  final Coin coin;
  final WalletConnection _connection;
  final WalletConnectSessionDelegate _delegate;
  final RemoteNotificationService _remoteNotificationService;
  final String accountId;
  final WalletConnectSessionEvents sessionEvents;
  final WalletConnectSessionDelegateEvents delegateEvents;
  final VoidCallback onSessionClosedRemotely;

  String? _peerId;
  String? _remotePeerId;
  ClientMeta? _clientMeta;

  WalletConnectAddress get address => _connection.address;
  String? get peerId => _peerId;
  String? get remotePeerId => _remotePeerId;
  ClientMeta? get clientMeta => _clientMeta;

  void _startSession(
      String peerId, String remotePeerId, ClientMeta clientMeta) {
    _peerId = peerId;
    _remotePeerId = remotePeerId;
    _clientMeta = clientMeta;
  }

  void _endSession() {
    _peerId = null;
    _remotePeerId = null;
    _clientMeta = null;
  }

  Future<bool> connect([
    WalletConnectSessionRestoreData? restoreData,
    Duration? timeoutDuration,
  ]) async {
    var success = false;
    var timeout = timeoutDuration ?? inactivityTimeout;
    try {
      _connection.addListener(_statusListener);

      final wrapperDelegate =
          WalletConnectSessionCapturingDelegate(this, _delegate);

      await _connection.connect(wrapperDelegate, restoreData?.data);

      success = true;

      if (restoreData != null) {
        _startInactivityTimer(timeout);

        log("Restored session: ${restoreData.data}");

        _startSession(restoreData.data.peerId, restoreData.data.remotePeerId,
            restoreData.clientMeta);

        sessionEvents._state.value =
            WalletConnectSessionState.connected(restoreData.clientMeta);

        _remoteNotificationService.registerForPushNotifications(_peerId!);
      }
    } on Exception catch (e) {
      _inactivityTimer?.cancel();
      _inactivityTimer = null;
      logError(
        'Failed to connect: $e',
      );
    }

    return success;
  }

  Future<void> closeButRetainSession() {
    _connection.removeListener(_statusListener);

    return _connection.dispose();
  }

  Future<bool> disconnect() async {
    _disconnect();

    if (_connection.value != WalletConnectState.disconnected) {
      await _connection.disconnect();

      if (_peerId != null) {
        _remoteNotificationService.unregisterForPushNotifications(_peerId!);
      }
    }

    _endSession();

    return true;
  }

  Future<void> dispose() async {
    // Keep socket open on the web by not disconnecting.
    // Allows restoration of connection when app is restarted.
    _connection.removeListener(_statusListener);
    await Future.wait([delegateEvents.dispose(), sessionEvents.dispose()]);
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    _startInactivityTimer(inactivityTimeout);

    return _delegate.complete(requestId, allowed);
  }

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  }) async {
    _startInactivityTimer(inactivityTimeout);

    return _delegate.complete(requestId, allowed);
  }

  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    _startInactivityTimer(inactivityTimeout);
    final success = await _delegate.complete(details.id, allowed);
    if (success) {
      sessionEvents._state.value =
          WalletConnectSessionState.connected(details.data.clientMeta);

      _remoteNotificationService.registerForPushNotifications(_peerId!);
    }

    return success;
  }

  void _disconnect() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
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
      onSessionClosedRemotely();
    } else if (status == WalletConnectState.connecting) {
      sessionEvents._state.value = WalletConnectSessionState.connecting();
    }
  }

  void _startInactivityTimer(Duration inactivityTimeout) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      if (_connection.value == WalletConnectState.connected) {
        disconnect();
      }
      onSessionClosedRemotely();
    });
  }
}
