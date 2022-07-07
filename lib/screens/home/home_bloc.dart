import 'dart:async';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/session_data.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionFactory = WalletConnection Function(
  WalletConnectAddress address,
);

class HomeBloc extends Disposable with WidgetsBindingObserver {
  HomeBloc() {
    get<DeepLinkService>()
        .link
        .listen(_handleDynamicLink)
        .addTo(_subscriptions);
    _transactionHandler.transaction
        .listen(_onTransaction)
        .addTo(_subscriptions);
    _accountService.events.selected
        .distinct()
        .listen(_onSelected)
        .addTo(_subscriptions);
    delegateEvents.onClose
        .listen((_) => _clearSessionData())
        .addTo(_subscriptions);
    WidgetsBinding.instance.addObserver(this);
  }

  WalletConnectSession? _currentSession;

  final _transactionDetails = BehaviorSubject.seeded(
    TransactionDetails(
      address: "",
      filteredTransactions: [],
      transactions: [],
    ),
  );
  final _isLoading = BehaviorSubject.seeded(false);
  final _transactionPages = BehaviorSubject.seeded(1);
  final _isLoadingTransactions = BehaviorSubject.seeded(false);
  final _assetList = BehaviorSubject<List<Asset>?>.seeded([]);
  final _error = PublishSubject<String>();

  final _subscriptions = CompositeSubscription();

  final _transactionHandler = get<TransactionHandler>();
  final _accountService = get<AccountService>();
  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  var _isFirstLoad = true;

  final delegateEvents = WalletConnectSessionDelegateEvents();
  final sessionEvents = WalletConnectSessionEvents();

  ValueStream<TransactionDetails> get transactionDetails => _transactionDetails;
  ValueStream<int> get transactionPages => _transactionPages;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<bool> get isLoadingTransactions => _isLoadingTransactions;
  ValueStream<List<Asset>?> get assetList => _assetList;
  Stream<String> get error => _error;

  WalletConnectSession? get currentSession => _currentSession;

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
        final accountId = _accountService.events.selected.value?.id;
        final sessionStatus =
            _currentSession?.sessionEvents.state.value.status ??
                WalletConnectSessionStatus.disconnected;
        final authStatus = get<LocalAuthHelper>().status.value;
        if (accountId != null &&
            sessionStatus == WalletConnectSessionStatus.disconnected &&
            authStatus == AuthStatus.authenticated) {
          tryRestoreSession(accountId);
        }
        break;
    }
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      final account = _accountService.events.selected.value;

      var assetList = <Asset>[];
      var transactions = <Transaction>[];

      if (account != null) {
        final isFirstLoad = _isFirstLoad;
        _isFirstLoad = false;

        final accountId = account.id;
        if (isFirstLoad) {
          tryRestoreSession(accountId);
        }

        assetList = await _assetService.getAssets(
          account.publicKey!.coin,
          account.publicKey!.address,
        );

        transactions = await _transactionService.getTransactions(
          account.publicKey!.coin,
          account.publicKey!.address,
          _transactionPages.value,
        );
      }

      _assetList.tryAdd(assetList);

      _transactionDetails.tryAdd(
        TransactionDetails(
          address: account?.publicKey?.address ?? '',
          filteredTransactions: transactions,
          transactions: transactions.toList(),
        ),
      );
    } finally {
      if (showLoading) {
        _isLoading.tryAdd(false);
      }
    }
  }

  Future<void> loadAdditionalTransactions() async {
    var oldDetails = _transactionDetails.value;
    var transactions = oldDetails.transactions;
    if (_transactionPages.value * 50 > transactions.length) {
      return;
    }
    _transactionPages.value++;
    _isLoadingTransactions.value = true;
    final account = _accountService.events.selected.value;

    if (account != null) {
      final newTransactions = await _transactionService.getTransactions(
        account.publicKey!.coin,
        account.publicKey!.address,
        _transactionPages.value,
      );
      if (newTransactions.isNotEmpty) {
        transactions.addAll(newTransactions);
      }
    }

    _transactionDetails.tryAdd(
      TransactionDetails(
        address: account?.publicKey?.address ?? '',
        filteredTransactions: oldDetails.filteredTransactions,
        transactions: transactions.toList(),
      ),
    );
    filterTransactions(oldDetails.selectedType, oldDetails.selectedStatus);

    _isLoadingTransactions.value = false;
  }

  void filterTransactions(String messageType, String status) {
    final stopwatch = Stopwatch()..start();
    var transactions = _transactionDetails.value.transactions;
    List<Transaction> filtered = [];
    if (messageType == Strings.dropDownAllMessageTypes &&
        status == Strings.dropDownAllStatuses) {
      filtered = transactions.toList();
    } else if (messageType == Strings.dropDownAllMessageTypes) {
      filtered = transactions.where((t) => t.status == status).toList();
    } else if (status == Strings.dropDownAllStatuses) {
      filtered =
          transactions.where((t) => t.messageType == messageType).toList();
    } else {
      filtered = transactions
          .where((t) => t.messageType == messageType && t.status == status)
          .toList();
    }
    _transactionDetails.tryAdd(TransactionDetails(
      address: _accountService.events.selected.value?.publicKey?.address ?? "",
      transactions: transactions,
      filteredTransactions: filtered,
      selectedStatus: status,
      selectedType: messageType,
    ));
    stopwatch.stop();
    logDebug(
      "Filtering transactions took ${stopwatch.elapsed.inMilliseconds / 1000} seconds.",
    );
  }

  Future<bool> connectSession(
    String accountId,
    String addressData, {
    SessionData? sessionData,
    Duration? remainingTime,
  }) async {
    var success = false;

    final oldSession = _currentSession;
    if (oldSession != null) {
      await oldSession.dispose();
    }

    final accountService = get<AccountService>();
    final privateKey = await accountService.loadKey(accountId);
    if (privateKey == null) {
      logError('Failed to locate the private key');

      return false;
    }

    final address = WalletConnectAddress.create(addressData);
    if (address == null) {
      logError('Invalid wallet connect address: $addressData');

      return false;
    }

    final accountDetails = _accountService.events.selected.value!;
    final connection = get<WalletConnectionFactory>().call(address);
    final remoteNotificationService = get<RemoteNotificationService>();
    final keyValueService = get<KeyValueService>();
    final queueServce = get<WalletConnectQueueService>();

    final delegate = WalletConnectSessionDelegate(
      privateKey: privateKey,
      transactionHandler: _transactionHandler,
      address: address,
      queueService: queueServce,
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
      remoteNotificationService: remoteNotificationService,
      keyValueService: keyValueService,
    );

    delegateEvents.listen(session.delegateEvents);
    sessionEvents.listen(session.sessionEvents);

    _currentSession = session;

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

    success = await session.connect(restoreData, remainingTime);

    return success;
  }

  Future<bool> disconnectSession() async {
    final success = await _currentSession?.disconnect() ?? false;

    await _clearSessionData();

    return success;
  }

  Future<bool> tryRestoreSession(String accountId) async {
    var success = false;
    final keyValueService = get<KeyValueService>();
    final json = await keyValueService.getString(PrefKey.sessionData);
    final date = DateTime.tryParse(
      await keyValueService.getString(PrefKey.sessionSuspendedTime) ?? "",
    );
    SessionData? data;

    if (json != null && date != null) {
      try {
        data = SessionData.fromJson(jsonDecode(json));
      } on Exception {
        logError('Failed to decode session data');
      }

      final remainingMinutes = 30 - DateTime.now().difference(date).inMinutes;

      if (data != null && data.accountId == accountId && remainingMinutes > 0) {
        success = await connectSession(
          accountId,
          data.address,
          sessionData: data,
          remainingTime: Duration(minutes: remainingMinutes),
        );

        if (!success) {
          await keyValueService.removeString(PrefKey.sessionData);
          await keyValueService.removeString(PrefKey.sessionSuspendedTime);
        }
      }
    }

    return success;
  }

  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    final session = _currentSession;
    if (session == null) {
      return false;
    }

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

      get<KeyValueService>()
          .setString(PrefKey.sessionData, jsonEncode(data.toJson()));
    }

    return approved;
  }

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

  Future<void> selectAccount({required String id}) async {
    await _currentSession?.disconnect();
    await get<AccountService>().selectAccount(id: id);
  }

  Future<void> renameAccount({
    required String id,
    required String name,
  }) async {
    await get<AccountService>().renameAccount(
      id: id,
      name: name,
    );
  }

  Future<Account?> setAccountCoin({
    required String id,
    required Coin coin,
  }) async {
    await _currentSession?.disconnect();

    return await get<AccountService>().setAccountCoin(id: id, coin: coin);
  }

  Future<bool> isValidWalletConnectAddress(String address) {
    return get<AccountService>().isValidWalletConnectData(address);
  }

  Future<void> resetAccounts() async {
    await disconnectSession();
    await get<AccountService>().resetAccounts();
    await get<CipherService>().deletePin();
    get<LocalAuthHelper>().reset();
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    delegateEvents.dispose();
    sessionEvents.dispose();

    _isLoading.close();
    _assetList.close();
    _transactionPages.close();
    _isLoadingTransactions.close();

    _transactionDetails.close();
    _error.close();

    _currentSession?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _onSelected(Account? details) {
    load();
  }

  void _onTransaction(TransactionResponse response) {
    load();
  }

  Future<bool> _clearSessionData() async {
    final keyValueService = get<KeyValueService>();
    final sessionDataRemoved =
        await keyValueService.removeString(PrefKey.sessionData);
    final timeStampRemoved =
        await keyValueService.removeString(PrefKey.sessionSuspendedTime);

    return sessionDataRemoved && timeStampRemoved;
  }

  Future<void> _handleDynamicLink(Uri link) async {
    final path = link.path;
    switch (path) {
      case '/wallet-connect':
        final data = link.queryParameters['data'];
        _handleWalletConnectLink(data);
        break;
      default:
        logError('Unhandled dynamic link: $path');
        break;
    }
  }

  Future<void> _handleWalletConnectLink(String? data) async {
    if (data != null) {
      final addressData = Uri.decodeComponent(data);
      final accountService = get<AccountService>();
      final isValid =
          await accountService.isValidWalletConnectData(addressData);
      final accountId = _accountService.events.selected.value?.id;
      if (isValid && accountId != null) {
        connectSession(accountId, addressData);
      } else {
        logError('Invalid wallet connect data');
      }
    }
  }
}

class TransactionDetails {
  TransactionDetails({
    required this.filteredTransactions,
    required this.transactions,
    this.selectedType = Strings.dropDownAllMessageTypes,
    this.selectedStatus = Strings.dropDownAllStatuses,
    required this.address,
  });
  List<String> _types = [];
  List<String> _statuses = [];

  List<Transaction> filteredTransactions;
  List<Transaction> transactions;
  String selectedType;
  String selectedStatus;
  String address;
  List<String> get types {
    if (_types.isNotEmpty) {
      return _types;
    }
    _types = [
      Strings.dropDownAllMessageTypes,
      ...transactions.map((e) => e.messageType).toSet().toList(),
    ];

    return _types;
  }

  List<String> get statuses {
    if (_statuses.isNotEmpty) {
      return _statuses;
    }
    _statuses = [
      Strings.dropDownAllStatuses,
      ...transactions
          .map(
            (e) => e.status,
          )
          .toSet()
          .toList(),
    ];

    return _statuses;
  }
}
