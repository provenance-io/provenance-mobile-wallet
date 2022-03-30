import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class AssetChartBloc extends Disposable {
  AssetChartBloc(this._asset);

  final Asset _asset;
  final _assetService = get<AssetService>();
  final _chartDetails = BehaviorSubject<AssetChartDetails?>.seeded(null);

  ValueStream<AssetChartDetails?> get chartDetails => _chartDetails.stream;

  Future<void> load({
    GraphingDataValue value = GraphingDataValue.hourly,
  }) async {
    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      [],
    );
    final graphItemList =
        await _assetService.getAssetGraphingData(_asset.denom, value);
    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      graphItemList,
    );
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
  );
  final GraphingDataValue value;
  final Asset asset;
  final List<AssetGraphItem> graphItemList;
}
