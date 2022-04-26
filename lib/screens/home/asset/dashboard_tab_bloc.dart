import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/home/asset/asset_details.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:rxdart/rxdart.dart';

class DashboardTabBloc extends Disposable {
  final _assetDetails = BehaviorSubject<AssetDetails?>.seeded(null);

  ValueStream<AssetDetails?> get assetDetails => _assetDetails;

  Future<void> openAsset(Coin coin, Asset asset) async {
    _assetDetails.value = AssetDetails(
      coin,
      asset,
      false,
    );
  }

  Future<void> openViewAllTransactions() async {
    final details = _assetDetails.value;
    if (null == details) {
      return;
    }
    _assetDetails.value = AssetDetails(
      details.coin,
      details.asset,
      true,
    );
  }

  Future<void> closeViewAllTransactions() async {
    final details = _assetDetails.value;
    if (null == details) {
      return;
    }
    _assetDetails.value = AssetDetails(
      details.coin,
      details.asset,
      false,
    );
  }

  Future<void> closeAsset() async {
    _assetDetails.value = null;
  }

  @override
  FutureOr onDispose() {
    _assetDetails.close();
  }
}
