import 'dart:async';

import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_client/transaction_client.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

class TransactionsBloc {
  TransactionsBloc({
    required String allMessageTypes,
    required String allStatuses,
  })  : _allMessageTypes = allMessageTypes,
        _allStatuses = allStatuses;

  final _transactionClient = get<TransactionClient>();
  final _accountService = get<AccountService>();
  final String _allMessageTypes;
  final String _allStatuses;

  final _transactionDetails = BehaviorSubject<TransactionDetails>();

  final _transactionPages = BehaviorSubject.seeded(1);
  final _isLoadingTransactions = BehaviorSubject.seeded(false);

  ValueStream<TransactionDetails> get transactionDetails => _transactionDetails;
  ValueStream<int> get transactionPages => _transactionPages;
  ValueStream<bool> get isLoadingTransactions => _isLoadingTransactions;

  Future<void> load() async {
    final account = _accountService.events.selected.value;

    var transactions = <Transaction>[];

    if (account != null) {
      _isLoadingTransactions.tryAdd(true);

      try {
        transactions = await _transactionClient.getTransactions(
          account.coin,
          account.address,
          _transactionPages.value,
        );
      } finally {
        _isLoadingTransactions.tryAdd(false);
      }
    }

    _transactionDetails.tryAdd(
      TransactionDetails(
        selectedStatus: _allStatuses,
        selectedType: _allMessageTypes,
        allMessageTypes: _allMessageTypes,
        allStatuses: _allStatuses,
        address: account?.address ?? '',
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
    final account = _accountService.events.selected.value;

    if (account != null) {
      final newTransactions = await _transactionClient.getTransactions(
        account.coin,
        account.address,
        _transactionPages.value,
      );
      if (newTransactions.isNotEmpty) {
        transactions.addAll(newTransactions);
      }
    }

    _transactionDetails.tryAdd(
      TransactionDetails(
        allMessageTypes: oldDetails.allMessageTypes,
        allStatuses: oldDetails.allStatuses,
        selectedStatus: oldDetails.selectedStatus,
        selectedType: oldDetails.selectedType,
        address: account?.address ?? '',
        filteredTransactions: oldDetails.filteredTransactions,
        transactions: transactions.toList(),
      ),
    );
    filterTransactions(oldDetails.selectedType, oldDetails.selectedStatus);

    _isLoadingTransactions.value = false;
  }

  void filterTransactions(String messageType, String status) {
    final stopwatch = Stopwatch()..start();
    final allMessageTypes = _transactionDetails.value.allMessageTypes;
    final allStatuses = _transactionDetails.value.allStatuses;

    var transactions = _transactionDetails.value.transactions;
    List<Transaction> filtered = [];
    if (messageType == allMessageTypes && status == allStatuses) {
      filtered = transactions.toList();
    } else if (messageType == allMessageTypes) {
      filtered = transactions.where((t) => t.status == status).toList();
    } else if (status == allStatuses) {
      filtered =
          transactions.where((t) => t.messageType == messageType).toList();
    } else {
      filtered = transactions
          .where((t) => t.messageType == messageType && t.status == status)
          .toList();
    }
    _transactionDetails.tryAdd(TransactionDetails(
      allMessageTypes: allMessageTypes,
      allStatuses: allStatuses,
      address: _accountService.events.selected.value?.address ?? "",
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

  void dispose() {
    _transactionPages.close();
    _isLoadingTransactions.close();
    _transactionDetails.close();
  }
}

class TransactionDetails {
  TransactionDetails({
    required this.allMessageTypes,
    required this.allStatuses,
    required this.filteredTransactions,
    required this.transactions,
    required this.selectedType,
    required this.selectedStatus,
    required this.address,
  });
  List<String> _types = [];
  List<String> _statuses = [];

  List<Transaction> filteredTransactions;
  List<Transaction> transactions;
  String allMessageTypes;
  String allStatuses;
  String selectedType;
  String selectedStatus;
  String address;
  List<String> get types {
    if (_types.isNotEmpty) {
      return _types;
    }
    _types = [
      allMessageTypes,
      ...transactions.map((e) => e.messageType).toSet().toList(),
    ];

    return _types;
  }

  List<String> get statuses {
    if (_statuses.isNotEmpty) {
      return _statuses;
    }
    _statuses = [
      allStatuses,
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
