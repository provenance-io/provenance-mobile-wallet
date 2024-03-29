import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/mixin/listenable_mixin.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/session_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

import 'models/session_action.dart';
import 'models/wallet_connect_session_status.dart';
import 'wallet_connect_session.dart';
import 'wallet_connect_session_delegate.dart';

class DefaultWalletConnectService extends WalletConnectService
    with ListenableMixin, WidgetsBindingObserver
    implements Disposable {
  DefaultWalletConnectService({
    required KeyValueService keyValueService,
    required AccountService accountService,
    required TxQueueService txQueueService,
    required WalletConnectionFactory connectionFactory,
    required RemoteNotificationService notificationService,
    required WalletConnectQueueService queueService,
    required LocalAuthHelper localAuthHelper,
  })  : _keyValueService = keyValueService,
        _accountService = accountService,
        _txQueueService = txQueueService,
        _connectionFactory = connectionFactory,
        _remoteNotificationService = notificationService,
        _queueServce = queueService,
        _localAuthHelper = localAuthHelper {
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

  final _accountServiceSubscriptions = CompositeSubscription();

  final KeyValueService _keyValueService;
  final AccountService _accountService;
  final TxQueueService _txQueueService;
  final WalletConnectionFactory _connectionFactory;
  final RemoteNotificationService _remoteNotificationService;
  final WalletConnectQueueService _queueServce;
  final LocalAuthHelper _localAuthHelper;

  late StreamSubscription _authSubscription;

  bool _isRestoring = false;

  void _log(String msg) {
    log("\x1B[32m$msg\x1B[0m");
  }

  void _setupAccountListeners() {
    callback(_) {
      _tryRestoreCurrentUserSession();
    }

    _accountService.events.selected
        .listen(callback)
        .addTo(_accountServiceSubscriptions);
  }

  Future<WalletConnectSession?> _doCreateConnection(
      TransactableAccount connectAccount,
      TransactableAccount transactAccount,
      String wcAddress,
      {String? peerId,
      String? remotePeerId,
      ClientMeta? clientMeta,
      Duration? timeout}) async {
    final privateKey = await _accountService.loadKey(
      connectAccount.id,
      connectAccount.coin,
    );

    final address = WalletConnectAddress.create(wcAddress);
    if (address == null) {
      logError('Invalid wallet connect address: $wcAddress');

      return null;
    }

    final connection = _connectionFactory(address);

    final delegate = WalletConnectSessionDelegate(
      connectAccount: connectAccount,
      transactAccount: transactAccount,
      accountService: _accountService,
      txQueueService: _txQueueService,
      connection: connection,
      queueService: _queueServce,
    );

    final session = WalletConnectSession(
        accountId: transactAccount.id,
        connection: connection,
        delegate: delegate,
        coin: transactAccount.coin,
        remoteNotificationService: _remoteNotificationService,
        onSessionClosedRemotelyDelegate: _onRemoveSessionClosed);

    WalletConnectSessionRestoreData? restoreData;
    if (clientMeta != null && peerId != null && remotePeerId != null) {
      restoreData = WalletConnectSessionRestoreData(
        clientMeta,
        SessionRestoreData(
          privateKey,
          privateKey.coin.chainId,
          peerId,
          remotePeerId,
        ),
      );
    }

    final connected = await session.connect(restoreData, timeout);
    if (!connected) {
      session.dispose();
      return null;
    } else {
      return session;
    }
  }

  Future<void> _setCurrentSession(WalletConnectSession? newSession) async {
    if (_currentSession == newSession) {
      return;
    }

    if (_currentSession != null) {
      try {
        await Future.value([
          _currentSession!.delegateEvents.clear(),
          _currentSession!.sessionEvents.clear()
        ]);

        await _queueServce.removeWalletConnectSessionGroup(
          accountId: _currentSession!.accountId,
        );

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

  void _onRemoveSessionClosed() {
    _currentSession = null;
    notifyListeners();
  }

  /* Disposable */

  @override
  FutureOr onDispose() async {
    WidgetsBinding.instance.removeObserver(this);

    await _setCurrentSession(null);
    await _accountServiceSubscriptions.dispose();
    await _authSubscription.cancel();
  }

  @override
  Future<bool> connectSession(
    String accountId,
    String addressData, {
    SessionData? sessionData,
    Duration? remainingTime,
  }) async {
    final account = _accountService.events.selected.value;
    if (account == null) {
      logError('No account currently selected');

      return false;
    }

    TransactableAccount connectAccount;
    TransactableAccount transactAccount;
    if (account is MultiTransactableAccount) {
      connectAccount = account.linkedAccount;
      transactAccount = account;
    } else {
      connectAccount = account;
      transactAccount = account;
    }

    final wcConnection =
        await _doCreateConnection(connectAccount, transactAccount, addressData);
    if (wcConnection == null) {
      return false;
    } else {
      await _setCurrentSession(wcConnection);
      return true;
    }
  }

  @visibleForTesting
  Future<WalletConnectSession?> tryRestoreSession(String accountId) async {
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
      await _removeSessionData(
        accountId: accountId,
      );
      return null;
    }

    final sessionExpired =
        suspensionTime.add(WalletConnectSession.inactivityTimeout);

    final now = DateTime.now();

    final account = await _accountService.getAccount(accountId);
    if (account is! TransactableAccount) {
      logError('Did not find valid account for id: $accountId');

      return null;
    }

    TransactableAccount connectAccount;
    TransactableAccount transactAccount;
    if (account is MultiTransactableAccount) {
      connectAccount = account.linkedAccount;
      transactAccount = account;
    } else {
      connectAccount = account;
      transactAccount = account;
    }

    _log("The existing session expires at ${sessionExpired.toIso8601String()}");
    final session = await _doCreateConnection(
        connectAccount, transactAccount, data.address,
        clientMeta: data.clientMeta,
        peerId: data.peerId,
        remotePeerId: data.remotePeerId);

    if (session == null) {
      return null;
    }

    if (now.isAfter(sessionExpired)) {
      _log("Disconnecting expired previous session");
      await session.disconnect();
      await session.dispose();
      await _removeSessionData(
        accountId: session.accountId,
      );
      return null;
    }

    return session;
  }

  @override
  Future<bool> approveSession({
    required SessionAction details,
    required bool allowed,
  }) async {
    final session = _currentSession;
    if (session == null) {
      _log("No session currently active");
      return false;
    }

    final success = await session.approveSession(
      details: details,
      allowed: allowed,
    );

    if (!allowed || !success) {
      _setCurrentSession(null);
    }

    return success;
  }

  @override
  Future<bool> disconnectSession() async {
    final accountId = _currentSession?.accountId;
    await _setCurrentSession(null);

    await _removeSessionData(
      accountId: accountId,
    );

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

      final deepLinkAddress =
          await _keyValueService.getString(PrefKey.deepLinkAddress);

      await _keyValueService.removeString(PrefKey.deepLinkAddress);

      final deepLinkWcAddress =
          WalletConnectAddress.create(deepLinkAddress ?? "");

      if (deepLinkWcAddress != null) {
        final session = await tryRestoreSession(currentUser.id);
        session?.disconnect();

        await connectSession(currentUser.id, deepLinkAddress!);
      } else {
        final session = await tryRestoreSession(currentUser.id);
        _setCurrentSession(session);
      }
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> _removeSessionData({String? accountId}) async {
    Future<void> removeSessionGroupFuture;

    if (accountId != null) {
      removeSessionGroupFuture = _queueServce.removeWalletConnectSessionGroup(
        accountId: accountId,
      );
    } else {
      removeSessionGroupFuture = Future.value();
    }

    _log("Removing session data");
    await Future.wait([
      _keyValueService.removeString(PrefKey.sessionData),
      _keyValueService.removeString(PrefKey.sessionSuspendedTime),
      removeSessionGroupFuture
    ]);
  }

  Future<void> _tryStoreSession(WalletConnectSession session) async {
    final remotePeerId = session.remotePeerId;
    final peerId = session.peerId;
    final address = session.address.raw;
    final clientMeta = session.clientMeta;

    if (remotePeerId != null && peerId != null && clientMeta != null) {
      final data = SessionData(
        session.accountId,
        peerId,
        remotePeerId,
        address,
        clientMeta,
      );

      final sessionJson = jsonEncode(data.toJson());
      final suspensionTime = DateTime.now().toIso8601String();

      _log("Storing session state: $sessionJson");

      await Future.wait([
        _keyValueService.setString(PrefKey.sessionData, sessionJson),
        _keyValueService.setString(
            PrefKey.sessionSuspendedTime, suspensionTime),
      ]);
    }
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
          final session = _currentSession!;
          _currentSession = null;

          _tryStoreSession(session).whenComplete(() async {
            await session.closeButRetainSession();
          });
        }
        break;
      case AppLifecycleState.resumed:
        _tryRestoreCurrentUserSession();
        break;
    }
  }
}
