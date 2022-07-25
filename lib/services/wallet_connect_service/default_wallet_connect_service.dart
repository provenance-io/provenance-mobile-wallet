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

  void _setupAccountListeners() {
    callback(_) {
      _onAccountChanged();
    }

    _accountService.events.added.listen(callback).addTo(_subscriptions);
    _accountService.events.removed.listen(callback).addTo(_subscriptions);
    _accountService.events.selected.listen(callback).addTo(_subscriptions);
    _accountService.events.updated.listen(callback).addTo(_subscriptions);
  }

  void _onAccountChanged() async {
    if (_currentSession == null) {
      return;
    }

    // TODO: if the account name changes should we update the dapp with the new name?
    final selectedAccount = _accountService.events.selected.value;
    final selectedAccountAddress = selectedAccount?.id;

    final didSelectedAccountChange =
        _currentSession?.accountId != selectedAccountAddress;

    final didNetworkChange =
        selectedAccount?.publicKey!.coin != _currentSession!.coin;

    log("""AccountService updated:
      selectedAccount is null: (${selectedAccount == null})
      didSelectedAccountChange: $didSelectedAccountChange
      didNetworkChange: $didNetworkChange
    """);

    if (selectedAccount == null ||
        didSelectedAccountChange ||
        didNetworkChange) {
      await _setCurrentSession(null);
    }
  }

  Future<void> _setCurrentSession(WalletConnectSession? newSession) async {
    if (_currentSession != null) {
      _currentSession!.delegateEvents.clear();
      _currentSession!.sessionEvents.clear();

      await _currentSession!.disconnect();
      await _currentSession!.dispose();
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
  }

  @override
  Future<bool> connectSession(
    String accountId,
    String addressData, {
    SessionData? sessionData,
    Duration? remainingTime,
  }) async {
    final oldSession = _currentSession;
    if (oldSession != null) {
      await oldSession.dispose();
    }

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

  @override
  Future<bool> tryRestoreSession(String accountId) async {
    final json = await _keyValueService.getString(PrefKey.sessionData);
    final date = DateTime.tryParse(
      await _keyValueService.getString(PrefKey.sessionSuspendedTime) ?? "",
    );

    SessionData? data;
    bool success = false;

    if (json != null && date != null) {
      try {
        data = SessionData.fromJson(jsonDecode(json));
      } on Exception {
        logError('Failed to decode session data');
      }

      final remainingMinutes = 30 - DateTime.now().difference(date).inMinutes;

      if (data != null && data.accountId == accountId && remainingMinutes > 0) {
        try {
          success = await connectSession(
            accountId,
            data.address,
            sessionData: data,
            remainingTime: Duration(minutes: remainingMinutes),
          );
        } catch (e) {
          await Future.wait([
            _keyValueService.removeString(PrefKey.sessionData),
            _keyValueService.removeString(PrefKey.sessionSuspendedTime)
          ]);
        }
      }
    }
    return success;
  }

  @override
  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    final session = _currentSession;
    if (session == null) {
      log("No session currently active");
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

    await Future.wait([
      _keyValueService.removeString(PrefKey.sessionData),
      _keyValueService.removeString(PrefKey.sessionSuspendedTime)
    ]);

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

  /* WidgetsBindingObserver */

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
        final accountService = get<AccountService>();
        final accountId = accountService.events.selected.value?.id;
        final sessionStatus =
            _currentSession?.sessionEvents.state.value.status ??
                WalletConnectSessionStatus.disconnected;
        final authStatus = get<LocalAuthHelper>().status.value;
        log("accountId = $accountId, sessionStatus = $sessionStatus, authStatus = $authStatus");
        if (accountId != null &&
            sessionStatus == WalletConnectSessionStatus.disconnected &&
            authStatus == AuthStatus.authenticated) {
          tryRestoreSession(accountId);
        }
        break;
    }
  }
}
