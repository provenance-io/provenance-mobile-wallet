import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/models/asset_statistic.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class AssetChartBloc extends Disposable {
  AssetChartBloc(this._asset);

  final Asset _asset;
  final _assetService = get<AssetService>();
  final _chartDetails = BehaviorSubject<AssetChartDetails?>.seeded(null);

  ValueStream<AssetChartDetails?> get chartDetails => _chartDetails.stream;

  Future<void> load(GraphingDataValue value) async {
    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      [],
      _chartDetails.value?.assetStatistics,
      false,
    );
    try {
      // This is gonna fail until these endpoints are built (or unless we are in mock)
      final graphItemList =
          await _assetService.getAssetGraphingData(_asset.denom, value);
      final assetStatistics =
          await _assetService.getAssetStatistics(_asset.denom);
      _chartDetails.value = AssetChartDetails(
        value,
        _asset,
        graphItemList,
        assetStatistics,
        false,
      );
    } catch (e) {
      _chartDetails.value = AssetChartDetails(
        value,
        _asset,
        [],
        null,
        true,
      );
    }
  }

  @override
  FutureOr onDispose() {
    _chartDetails.close();
  }
}

class AssetChartDetails {
  AssetChartDetails(
    this.value,
    this.asset,
    this.graphItemList,
    this.assetStatistics,
    this.isComingSoon,
  );
  final GraphingDataValue value;
  final Asset asset;
  final List<AssetGraphItem> graphItemList;
  final AssetStatistics? assetStatistics;
  final bool isComingSoon;
}
