import 'dart:async';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/session_data.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_restore_data.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionFactory = WalletConnection Function(
  WalletConnectAddress address,
);

class DashboardBloc extends Disposable with WidgetsBindingObserver {
  DashboardBloc() {
    get<DeepLinkService>()
        .link
        .listen(_handleDynamicLink)
        .addTo(_subscriptions);
    _transactionHandler.transaction
        .listen(_onTransaction)
        .addTo(_subscriptions);
    _walletService.events.selected
        .distinct()
        .listen(_onSelected)
        .addTo(_subscriptions);
    delegateEvents.onClose
        .listen((_) => _clearSessionData())
        .addTo(_subscriptions);
    WidgetsBinding.instance?.addObserver(this);
  }

  WalletConnectSession? _walletSession;

  final _transactionDetails = BehaviorSubject.seeded(
    TransactionDetails(
      walletAddress: "",
      filteredTransactions: [],
      transactions: [],
    ),
  );
  final _transactionPages = BehaviorSubject.seeded(1);
  final _isLoadingTransactions = BehaviorSubject.seeded(false);
  final _assetList = BehaviorSubject<List<Asset>?>.seeded([]);
  final _error = PublishSubject<String>();

  final _subscriptions = CompositeSubscription();

  final _transactionHandler = get<TransactionHandler>();
  final _walletService = get<WalletService>();
  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  var _isFirstLoad = true;

  final delegateEvents = WalletConnectSessionDelegateEvents();
  final sessionEvents = WalletConnectSessionEvents();

  ValueStream<TransactionDetails> get transactionDetails => _transactionDetails;
  ValueStream<int> get transactionPages => _transactionPages;
  ValueStream<bool> get isLoadingTransactions => _isLoadingTransactions;
  ValueStream<List<Asset>?> get assetList => _assetList;
  Stream<String> get error => _error;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final walletId = _walletService.events.selected.value?.id;
      final sessionStatus = _walletSession?.sessionEvents.state.value.status ??
          WalletConnectSessionStatus.disconnected;
      final authStatus = get<LocalAuthHelper>().status.value;
      if (walletId != null &&
          sessionStatus == WalletConnectSessionStatus.disconnected &&
          authStatus == AuthStatus.authenticated) {
        tryRestoreSession(walletId);
      }
    } else if (state == AppLifecycleState.paused) {
      if (_walletSession != null) {
        _walletSession!.closeButRetainSession();
        _walletSession = null;
      }
    }
  }

  Future<void> load() async {
    final wallet = _walletService.events.selected.value;

    var assetList = <Asset>[];
    var transactions = <Transaction>[];

    if (wallet != null) {
      final isFirstLoad = _isFirstLoad;
      _isFirstLoad = false;

      final walletId = wallet.id;
      if (isFirstLoad) {
        tryRestoreSession(walletId);
      }

      assetList = await _assetService.getAssets(
        wallet.coin,
        wallet.address,
      );

      transactions = await _transactionService.getTransactions(
        wallet.coin,
        wallet.address,
        _transactionPages.value,
      );
    }

    _assetList.tryAdd(assetList);

    _transactionDetails.tryAdd(
      TransactionDetails(
        walletAddress: wallet?.address ?? '',
        filteredTransactions: transactions,
        transactions: transactions.toList(),
      ),
    );
  }

  Future<void> loadAdditionalTransactions() async {
    var oldDetails = _transactionDetails.value;
    var transactions = oldDetails.transactions;
    if (_transactionPages.value * 50 > transactions.length) {
      return;
    }
    _transactionPages.value++;
    _isLoadingTransactions.value = true;
    final wallet = _walletService.events.selected.value;

    if (wallet != null) {
      final newTransactions = await _transactionService.getTransactions(
        wallet.coin,
        wallet.address,
        _transactionPages.value,
      );
      if (newTransactions.isNotEmpty) {
        transactions.addAll(newTransactions);
      }
    }

    _transactionDetails.tryAdd(
      TransactionDetails(
        walletAddress: wallet?.address ?? '',
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
          .where((t) =>
              t.messageType == messageType && t.status == status.toUpperCase())
          .toList();
    }
    _transactionDetails.tryAdd(TransactionDetails(
      walletAddress: _walletService.events.selected.value?.address ?? "",
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
    String walletId,
    String addressData, {
    SessionData? sessionData,
  }) async {
    var success = false;

    final oldSession = _walletSession;
    if (oldSession != null) {
      await oldSession.dispose();
    }

    final walletService = get<WalletService>();
    final privateKey = await walletService.loadKey(walletId);
    if (privateKey == null) {
      logError('Failed to locate the private key');

      return false;
    }

    final address = WalletConnectAddress.create(addressData);
    if (address == null) {
      logError('Invalid wallet connect address: $addressData');

      return false;
    }

    final walletDetails = _walletService.events.selected.value!;
    final connection = get<WalletConnectionFactory>().call(address);
    final remoteNotificationService = get<RemoteNotificationService>();

    final delegate = WalletConnectSessionDelegate(
      privateKey: privateKey,
      transactionHandler: _transactionHandler,
      walletInfo: WalletInfo(
        walletDetails.id,
        walletDetails.name,
        walletDetails.coin,
      ),
    );
    final session = WalletConnectSession(
      walletId: walletId,
      connection: connection,
      delegate: delegate,
      remoteNotificationService: remoteNotificationService,
    );

    delegateEvents.listen(session.delegateEvents);
    sessionEvents.listen(session.sessionEvents);

    _walletSession = session;

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

    success = await session.connect(restoreData);

    return success;
  }

  Future<bool> disconnectSession() async {
    final success = await _walletSession?.disconnect() ?? false;

    await _clearSessionData();

    return success;
  }

  Future<bool> tryRestoreSession(String walletId) async {
    var success = false;
    final json = await get<KeyValueService>().getString(PrefKey.sessionData);
    SessionData? data;
    if (json != null) {
      try {
        data = SessionData.fromJson(jsonDecode(json));
      } on Exception {
        logError('Failed to decode session data');
      }

      if (data != null && data.walletId == walletId) {
        success = await connectSession(
          walletId,
          data.address,
          sessionData: data,
        );

        if (!success) {
          await get<KeyValueService>().removeString(PrefKey.sessionData);
        }
      }
    }

    return success;
  }

  Future<bool> approveSession({
    required WalletConnectSessionRequestData details,
    required bool allowed,
  }) async {
    final session = _walletSession;
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
        session.walletId,
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
    return await _walletSession?.sendMessageFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<bool> signTransactionFinish({
    required String requestId,
    required bool allowed,
  }) async {
    return await _walletSession?.signTransactionFinish(
          requestId: requestId,
          allowed: allowed,
        ) ??
        false;
  }

  Future<void> selectWallet({required String id}) async {
    await _walletSession?.disconnect();
    await get<WalletService>().selectWallet(id: id);
  }

  Future<void> renameWallet({
    required String id,
    required String name,
  }) async {
    await get<WalletService>().renameWallet(
      id: id,
      name: name,
    );
  }

  Future<bool> isValidWalletConnectAddress(String address) {
    return get<WalletService>().isValidWalletConnectData(address);
  }

  Future<void> resetWallets() async {
    await disconnectSession();
    await get<WalletService>().resetWallets();
    await get<CipherService>().deletePin();
    get<LocalAuthHelper>().reset();
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    delegateEvents.dispose();
    sessionEvents.dispose();

    _assetList.close();
    _transactionPages.close();
    _isLoadingTransactions.close();

    _transactionDetails.close();
    _error.close();

    _walletSession?.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  void _onSelected(WalletDetails? details) {
    load();
  }

  void _onTransaction(TransactionResponse response) {
    load();
  }

  Future<bool> _clearSessionData() {
    return get<KeyValueService>().removeString(PrefKey.sessionData);
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
      final walletService = get<WalletService>();
      final isValid = await walletService.isValidWalletConnectData(addressData);
      final walletId = _walletService.events.selected.value?.id;
      if (isValid && walletId != null) {
        connectSession(walletId, addressData);
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
    required this.walletAddress,
  });
  List<String> _types = [];
  List<String> _statuses = [];

  List<Transaction> filteredTransactions;
  List<Transaction> transactions;
  String selectedType;
  String selectedStatus;
  String walletAddress;
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
