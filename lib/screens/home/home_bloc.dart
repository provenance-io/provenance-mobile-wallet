import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends Disposable {
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
  }

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
  final _walletConnectService = get<WalletConnectService>();

  ValueStream<TransactionDetails> get transactionDetails => _transactionDetails;
  ValueStream<int> get transactionPages => _transactionPages;
  ValueStream<bool> get isLoading => _isLoading;
  ValueStream<bool> get isLoadingTransactions => _isLoadingTransactions;
  ValueStream<List<Asset>?> get assetList => _assetList;
  Stream<String> get error => _error;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading.tryAdd(true);
    }

    try {
      final account = _accountService.events.selected.value;

      var assetList = <Asset>[];
      var transactions = <Transaction>[];

      if (account != null) {
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

  Future<void> selectAccount({required String id}) async {
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
    return await get<AccountService>().setAccountCoin(id: id, coin: coin);
  }

  Future<bool> isValidWalletConnectAddress(String address) {
    return get<AccountService>().isValidWalletConnectData(address);
  }

  Future<void> resetAccounts() async {
    await get<AccountService>().resetAccounts();
    await get<CipherService>().deletePin();
    get<LocalAuthHelper>().reset();
  }

  @override
  FutureOr onDispose() {
    _subscriptions.dispose();

    _isLoading.close();
    _assetList.close();
    _transactionPages.close();
    _isLoadingTransactions.close();

    _transactionDetails.close();
    _error.close();
  }

  void _onSelected(Account? details) {
    load();
  }

  void _onTransaction(TransactionResponse response) {
    load();
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
        _walletConnectService.connectSession(accountId, addressData);
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
