import 'dart:async';

import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/network/models/transaction_response.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class DashboardBloc extends Disposable {
  final BehaviorSubject<List<TransactionResponse>> _transactionList =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<AssetResponse>> _assetList =
      BehaviorSubject.seeded([]);

  final _assetService = get<AssetService>();
  final _transactionService = get<TransactionService>();

  ValueStream<List<TransactionResponse>> get transactionList =>
      _transactionList.stream;
  ValueStream<List<AssetResponse>> get assetList => _assetList.stream;

  // TODO: Catch and display errors?
  void load(String walletAddress) async {
    _assetList.value =
        (await _assetService.getAssets(walletAddress)).data ?? [];
    _transactionList.value =
        (await _transactionService.getTransactions(walletAddress)).data ?? [];
  }

  @override
  FutureOr onDispose() {
    _assetList.close();
    _transactionList.close();
  }
}
