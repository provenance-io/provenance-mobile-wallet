import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/remote_client_details.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class DashboardBloc extends Disposable {
  DashboardBloc() {
    get<DeepLinkService>()
        .link
        .listen(_handleDynamicLink)
        .addTo(_subscriptions);
    walletEvents.listen(get<WalletService>().events);
    walletEvents.selected
        .distinct((a, b) => a?.id == b?.id)
        .listen(_onSelected)
        .addTo(_subscriptions);
    walletEvents.removed.listen(_onRemoved).addTo(_subscriptions);
    walletEvents.added.listen(_onAdded).addTo(_subscriptions);
    walletEvents.updated.listen(_onUpdated).addTo(_subscriptions);
  }

  WalletConnectSession? _walletSession;

  final _transactionDetails = BehaviorSubject.seeded(
    TransactionDetails(
      walletAddress: "",
      filteredTransactions: [],
      transactions: [],
    ),
  );
  final _walletMap = BehaviorSubject.seeded(<WalletDetails, int>{});
  final _assetList = BehaviorSubject.seeded(<Asset>[]);
  final _selectedWallet = BehaviorSubject<WalletDetails?>.seeded(null);
  final _error = PublishSubject<String>();

  final _subscriptions = CompositeSubscription();

  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  final delegateEvents = WalletConnectSessionDelegateEvents();
  final sessionEvents = WalletConnectSessionEvents();
  final walletEvents = WalletServiceEvents();

  ValueStream<TransactionDetails> get transactionDetails => _transactionDetails;
  ValueStream<List<Asset>?> get assetList => _assetList;
  ValueStream<WalletDetails?> get selectedWallet => _selectedWallet.stream;
  ValueStream<Map<WalletDetails, int>> get walletMap => _walletMap;
  Stream<String> get error => _error;

  Future<void> load() async {
    final walletService = get<WalletService>();
    var details = await walletService.getSelectedWallet();
    details ??= await walletService.selectWallet();

    _selectedWallet.tryAdd(details);
    var errorCount = 0;
    try {
      final assetList = await _assetService.getAssets(details?.address ?? "");
      _assetList.tryAdd(assetList);
    } catch (e) {
      errorCount++;
      _assetList.value = [];
    }

    try {
      var transactions =
          (await _transactionService.getTransactions(details?.address ?? ""));
      _transactionDetails.tryAdd(TransactionDetails(
        walletAddress: _selectedWallet.value?.address ?? "",
        filteredTransactions: transactions,
        transactions: transactions.toList(),
      ));
    } catch (e) {
      errorCount++;
      transactionDetails.value.transactions =
          transactionDetails.value.filteredTransactions = [];
      if (errorCount == 2) {
        _error.tryAdd(Strings.theSystemIsDown);
      }
    }
  }

  void filterTransactions(String denom, String status) {
    final stopwatch = Stopwatch()..start();
    var transactions = _transactionDetails.value.transactions;
    List<Transaction> filtered = [];
    if (denom == Strings.dropDownAllAssets &&
        status == Strings.dropDownAllTransactions) {
      filtered = transactions.toList();
    } else if (denom == Strings.dropDownAllAssets) {
      filtered =
          transactions.where((t) => t.status == status.toUpperCase()).toList();
    } else if (status == Strings.dropDownAllTransactions) {
      filtered = transactions.where((t) => t.denom == denom).toList();
    } else {
      filtered = transactions
          .where((t) => t.denom == denom && t.status == status.toUpperCase())
          .toList();
    }
    _transactionDetails.value = TransactionDetails(
      walletAddress: _selectedWallet.value?.address ?? "",
      transactions: transactions,
      filteredTransactions: filtered,
      selectedStatus: status,
      selectedType: denom,
    );
    stopwatch.stop();
    logDebug(
      "Filtering transactions took ${stopwatch.elapsed.inMilliseconds / 1000} seconds.",
    );
  }

  Future<void> connectWallet(String addressData) async {
    final oldSession = _walletSession;
    if (oldSession != null) {
      await oldSession.dispose();
    }

    final session = await get<WalletService>().createSession(addressData);
    if (session != null) {
      _walletSession = session;

      delegateEvents.listen(session.delegateEvents);
      sessionEvents.listen(session.sessionEvents);

      final success = await session.connect();
      if (success) {
        logDebug('Session connect succeeded');
      } else {
        logDebug('Session connect failed');
      }
    }
  }

  Future<bool> disconnectWallet() async {
    final success = await _walletSession?.disconnect() ?? false;

    return success;
  }

  Future<bool> approveSession({
    required RemoteClientDetails details,
    required bool allowed,
  }) async {
    return await _walletSession?.approveSession(
          details: details,
          allowed: allowed,
        ) ??
        false;
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
    await disconnectWallet();
    await get<WalletService>().resetWallets();
    await loadAllWallets();
  }

  Future<void> loadAllWallets() async {
    final walletService = get<WalletService>();
    final currentWallet = await walletService.getSelectedWallet();

    var list = (await walletService.getWallets());
    list.sort((a, b) {
      if (b.address == currentWallet?.address) {
        return 1;
      } else if (a.address == currentWallet?.address) {
        return -1;
      } else {
        return 0;
      }
    });

    Map<WalletDetails, int> map = {};

    for (var wallet in list) {
      var assets = wallet.address == selectedWallet.value?.address
          ? assetList.value
          : (await _assetService.getAssets(wallet.address));
      map[wallet] = assets?.length ?? 1;
    }

    _walletMap.value = map;
    _selectedWallet.value = currentWallet;
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();
    delegateEvents.dispose();
    sessionEvents.dispose();
    walletEvents.dispose();

    _assetList.close();

    _transactionDetails.close();
    _error.close();

    _walletSession?.dispose();
  }

  void _onSelected(WalletDetails? details) {
    _selectedWallet.value = details;
    load();
    loadAllWallets();
  }

  void _onRemoved(List<WalletDetails> removed) {
    if (removed.any((e) => e.id == _selectedWallet.value?.id)) {
      get<WalletService>().selectWallet();
    }

    loadAllWallets();
  }

  void _onAdded(WalletDetails details) {
    _selectedWallet.value ??= details;

    loadAllWallets();
  }

  void _onUpdated(WalletDetails details) {
    if (_selectedWallet.value?.id == details.id) {
      _selectedWallet.value = details;
    }

    loadAllWallets();
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
      if (isValid) {
        connectWallet(addressData);
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
    this.selectedType = Strings.dropDownAllAssets,
    this.selectedStatus = Strings.dropDownAllTransactions,
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
      Strings.dropDownAllAssets,
      ...transactions.map((e) => e.denom).toSet().toList(),
    ];

    return _types;
  }

  List<String> get statuses {
    if (_statuses.isNotEmpty) {
      return _statuses;
    }
    _statuses = [
      Strings.dropDownAllTransactions,
      ...transactions
          .map(
            (e) => e.status.toLowerCase().capitalize(),
          )
          .toSet()
          .toList(),
    ];

    return _statuses;
  }
}
