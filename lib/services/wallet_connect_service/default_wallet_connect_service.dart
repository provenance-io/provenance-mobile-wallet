import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/session_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class DefaultWalletConnectService extends WalletConnectService
    with ListenableMixin, WidgetsBindingObserver
    implements Disposable {
  DefaultWalletConnectService() {
    WidgetsBinding.instance.addObserver(this);

    _authSubscription = _localAuthHelper.status.listen((authStatus) {
      _log("AuthStatus updated: ${authStatus.toString()}");
      if (authStatus == AuthStatus.noAccount) {
        // there are no longer any valid accounts so close any existing session
        _setCurrentSession(null);
      } else {
        _tryRestoreCurrentUserSession();
      }
    });

    _setupAccountListeners();
  }

  WalletConnectSession? _currentSession;

  final _subscriptions = CompositeSubscription();
  final _keyValueService = get<KeyValueService>();
  final _accountService = get<AccountService>();
  final _connectionFactory = get<WalletConnectionFactory>();
  final _remoteNotificationService = get<RemoteNotificationService>();
  final _queueServce = get<WalletConnectQueueService>();
  final _transactionHandler = get<TransactionHandler>();
  final _localAuthHelper = get<LocalAuthHelper>();

  late StreamSubscription _authSubscription;

  bool _isRestoring = false;

  void _log(String msg) {
    log("\x1B[32m$msg\x1B[0m");
  }

  void _setupAccountListeners() {
    callback(_) {
      _tryRestoreCurrentUserSession();
    }

    _accountService.events.selected.listen(callback).addTo(_subscriptions);
  }

  Future<void> _setCurrentSession(WalletConnectSession? newSession) async {
    if (_currentSession != null) {
      try {
        _currentSession!.delegateEvents.clear();
        _currentSession!.sessionEvents.clear();

        await _queueServce
            .removeWalletConnectSessionGroup(_currentSession!.address);
        await _currentSession!.disconnect();
        await _currentSession!.dispose();
      } catch (e) {
        _log("An error occurred while closing an old session: ${e.toString()}");
      }
    }

    _currentSession = newSession;

    if (newSession != null) {
      sessionEvents.listen(_currentSession!.sessionEvents);
      delegateEvents.listen(_currentSession!.delegateEvents);
    }

    notifyListeners();
  }

  /* Disposable */

  @override
  FutureOr onDispose() async {
    WidgetsBinding.instance.removeObserver(this);

    await _setCurrentSession(null);
    await _subscriptions.dispose();
    await _authSubscription.cancel();
  }

  @override
  Future<bool> connectSession(
    String accountId,
    String addressData, {
    SessionData? sessionData,
    Duration? remainingTime,
  }) async {
    // final oldSession = _currentSession;
    // if (oldSession != null) {
    //   await oldSession.dispose();
    // }

    final privateKey = await _accountService.loadKey(accountId);
    if (privateKey == null) {
      logError('Failed to locate the private key');

      return false;
    }

    final address = WalletConnectAddress.create(addressData);
    if (address == null) {
      logError('Invalid wallet connect address: $addressData');

      return false;
    }

    final accountDetails = _accountService.events.selected.value;
    if (accountDetails == null) {
      logError('No account currently selected');

      return false;
    }

    final connection = _connectionFactory(address);

    final delegate = WalletConnectSessionDelegate(
      privateKey: privateKey,
      transactionHandler: _transactionHandler,
      address: address,
      queueService: _queueServce,
      connection: connection,
      walletInfo: WalletInfo(
        accountDetails.id,
        accountDetails.name,
        accountDetails.publicKey!.coin,
      ),
    );

    final session = WalletConnectSession(
      accountId: accountId,
      connection: connection,
      delegate: delegate,
      coin: accountDetails.publicKey!.coin,
      remoteNotificationService: _remoteNotificationService,
      keyValueService: _keyValueService,
    );

    WalletConnectSessionRestoreData? restoreData;
    if (sessionData != null) {
      final peerId = sessionData.peerId;
      final remotePeerId = sessionData.remotePeerId;
      final chainId = ChainId.forCoin(privateKey.publicKey.coin);

      restoreData = WalletConnectSessionRestoreData(
        sessionData.clientMeta,
        SessionRestoreData(
          privateKey,
          chainId,
          peerId,
          remotePeerId,
        ),
      );
    }

    return session.connect(restoreData, remainingTime).then((value) async {
      await _setCurrentSession(session);
      return value;
    });
  }

  Future<bool> tryRestoreSession(String accountId) async {
    final sessionValues = await Future.wait([
      _keyValueService.getString(PrefKey.sessionData),
      _keyValueService.getString(PrefKey.sessionSuspendedTime)
    ]);

    final suspensionTime = DateTime.tryParse(sessionValues[1] ?? "");
    SessionData? data;

    try {
      final sessionJson = sessionValues[0];
      if (sessionJson?.isNotEmpty ?? false) {
        data = SessionData.fromJson(jsonDecode(sessionJson!));
      }
    } catch (e) {
      logError('Failed to decode session data');
    }

    if (data == null || suspensionTime == null) {
      _log("No WalletConnect session to restore");
      await _removeSessionData();
      return false;
    }

    final sessionExpired =
        suspensionTime.add(WalletConnectSession.inactivityTimeout);

    final now = DateTime.now();

    _log("The existing session expires at ${sessionExpired.toIso8601String()}");

    final privateKey = await _accountService.loadKey(accountId);
    if (privateKey == null) {
      logError('Failed to locate the private key');
      return false;
    }

    final address = WalletConnectAddress.create(data.address);
    if (address == null) {
      logError('Invalid wallet connect address: $data.address');

      return false;
    }

    final accountDetails = await _accountService.getAccount(accountId);
    if (accountDetails == null) {
      logError('No account currently selected');

      return false;
    }

    final connection = _connectionFactory(address);

    final delegate = WalletConnectSessionDelegate(
      privateKey: privateKey,
      transactionHandler: _transactionHandler,
      address: address,
      queueService: _queueServce,
      walletInfo: WalletInfo(
        accountDetails.id,
        accountDetails.name,
        accountDetails.publicKey!.coin,
      ),
    );

    final session = WalletConnectSession(
      accountId: accountId,
      connection: connection,
      delegate: delegate,
      coin: accountDetails.publicKey!.coin,
      remoteNotificationService: _remoteNotificationService,
      keyValueService: _keyValueService,
    );

    WalletConnectSessionRestoreData restoreData =
        WalletConnectSessionRestoreData(
      data.clientMeta,
      SessionRestoreData(
        privateKey,
        ChainId.forCoin(privateKey.coin),
        data.peerId,
        data.remotePeerId,
      ),
    );

    try {
      final success =
          await session.connect(restoreData, sessionExpired.difference(now));

      if (success) {
        if (now.isAfter(sessionExpired)) {
          _log("Disconnecting expired previous session");
          await session.disconnect();
          await session.dispose();

          _log("The stored session has expired");
          await _removeSessionData();
          return false;
        } else {
          _log("Previous session has been restored");
          await _setCurrentSession(session);
        }
      }

      return success;
    } catch (err) {
      logError("Error restoring session: ${err.toString()}");
      session.dispose();
      rethrow;
    }
  }

  @override
  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    final session = _currentSession;
    if (session == null) {
      _log("No session currently active");
      return false;
    }

    bool success = false;
    final approved = await session.approveSession(
      details: details,
      allowed: allowed,
    );

    if (approved) {
      final remotePeerId = details.data.remotePeerId;
      final peerId = details.data.peerId;
      final address = details.data.address.raw;

      final data = SessionData(
        session.accountId,
        peerId,
        remotePeerId,
        address,
        details.data.clientMeta,
      );

      _keyValueService.setString(
          PrefKey.sessionData, jsonEncode(data.toJson()));
      success = true;
    }
    return success;
  }

  @override
  Future<bool> disconnectSession() async {
    await _setCurrentSession(null);

    await _removeSessionData();

    return true;
  }

  @override
  Future<bool> sendMessageFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return await _currentSession?.sendMessageFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  @override
  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return await _currentSession?.signTransactionFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<void> _tryRestoreCurrentUserSession() async {
    if (_isRestoring) {
      return;
    }

    _isRestoring = true;

    try {
      final authStatus = _localAuthHelper.status.value;
      final currentUser = _accountService.events.selected.value;

      if (authStatus != AuthStatus.authenticated || currentUser == null) {
        _log(
            "_tryRestoreCurrentUserSession\n\tauthStatus: ${authStatus.toString()}\n\tcurrentUser: $currentUser");
        return;
      }

      if (_currentSession != null) {
        if (_currentSession!.accountId != currentUser.id) {
          await _setCurrentSession(null);
        } else if (_currentSession!.sessionEvents.state.value.status !=
            WalletConnectSessionStatus.disconnected) {
          _log("Reusing existing active connection");
          return;
        }
      }

      await tryRestoreSession(currentUser.id);
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> _removeSessionData() {
    _log("Removing session data");
    return Future.wait([
      _keyValueService.removeString(PrefKey.sessionData),
      _keyValueService.removeString(PrefKey.sessionSuspendedTime)
    ]);
  }

  /* WidgetsBindingObserver */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log("didChangeAppLifecycleState: ${state.toString()}");
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_currentSession != null) {
          _currentSession!.closeButRetainSession();
          _currentSession = null;
        }
        break;
      case AppLifecycleState.resumed:
        _tryRestoreCurrentUserSession();
        break;
    }
  }
}
