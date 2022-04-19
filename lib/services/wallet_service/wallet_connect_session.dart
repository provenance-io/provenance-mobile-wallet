import 'dart:async';
import 'dart:developer';

import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/util/get.dart';
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

  void clear() {
    _subscriptions.clear();
  }

  void dispose() {
    _subscriptions.dispose();
    _state.close();
    _error.close();
  }
}

class WalletConnectSession {
  WalletConnectSession({
    required this.walletId,
    required WalletConnection connection,
    required WalletConnectSessionDelegate delegate,
    required RemoteNotificationService remoteNotificationService,
  })  : _connection = connection,
        _remoteNotificationService = remoteNotificationService,
        _delegate = delegate,
        sessionEvents = WalletConnectSessionEvents(),
        delegateEvents = WalletConnectSessionDelegateEvents()
          ..listen(delegate.events);

  static const _inactivityTimeout = Duration(minutes: 30);
  Timer? _inactivityTimer;
  final WalletConnection _connection;
  final WalletConnectSessionDelegate _delegate;
  final RemoteNotificationService _remoteNotificationService;
  final String walletId;
  final WalletConnectSessionEvents sessionEvents;
  final WalletConnectSessionDelegateEvents delegateEvents;

  String? topic;

  Future<bool> connect([
    WalletConnectSessionRestoreData? restoreData,
    Duration? timeoutDuration,
  ]) async {
    var success = false;
    var inactivityTimeout = timeoutDuration ?? _inactivityTimeout;
    try {
      _connection.addListener(_statusListener);

      await _connection.connect(_delegate, restoreData?.data);

      success = true;

      if (restoreData != null) {
        _startInactivityTimer(inactivityTimeout);

        log("Restored session: ${restoreData.data}");
        sessionEvents._state.value =
            WalletConnectSessionState.connected(restoreData.clientMeta);

        topic = restoreData.data.peerId;

        _remoteNotificationService.registerForPushNotifications(topic!);
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

      _remoteNotificationService.unregisterForPushNotifications(topic!);
    }

    return true;
  }

  Future<void> dispose() async {
    // Keep socket open on the web by not disconnecting.
    // Allows restoration of connection when app is restarted.
    _connection.removeListener(_statusListener);
    delegateEvents.dispose();
    sessionEvents.dispose();
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    _startInactivityTimer(_inactivityTimeout);

    return _delegate.complete(requestId, allowed);
  }

  Future<bool> sendMessageFinish({
    required requestId,
    required bool allowed,
  }) async {
    _startInactivityTimer(_inactivityTimeout);

    return _delegate.complete(requestId, allowed);
  }

  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    _startInactivityTimer(_inactivityTimeout);
    final success = await _delegate.complete(details.id, allowed);
    if (success) {
      sessionEvents._state.value =
          WalletConnectSessionState.connected(details.data.clientMeta);

      topic = details.data.peerId;
      _remoteNotificationService.registerForPushNotifications(topic!);
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
    } else if (status == WalletConnectState.connecting) {
      sessionEvents._state.value = WalletConnectSessionState.connecting();
    }
  }

  void _startInactivityTimer(Duration inactivityTimeout) {
    get<KeyValueService>().setString(
      PrefKey.sessionSuspendedTime,
      DateTime.now().toIso8601String(),
    );
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      disconnect();
    });
  }
}
