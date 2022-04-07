import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/date_time.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

class AssetChartBloc extends Disposable {
  AssetChartBloc(this._coin, this._asset);

  final Coin _coin;
  final Asset _asset;
  final _assetService = get<AssetService>();
  final _chartDetails = BehaviorSubject<AssetChartDetails?>.seeded(null);

  ValueStream<AssetChartDetails?> get chartDetails => _chartDetails.stream;

  Future<void> load({
    required DateTime startDate,
    required DateTime endDate,
    GraphingDataValue value = GraphingDataValue.hourly,
  }) async {
    startDate = startDate.startOfDay;
    endDate = endDate.endOfDay;
    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      [],
      false,
      startDate,
      endDate,
    );

    final graphItemList = await _assetService.getAssetGraphingData(
      _coin,
      _asset.denom,
      value,
      startDate: startDate,
      endDate: endDate,
    );

    // the price is in units of the base type, but we want to display
    // in the more convenient type
    final scaleValue = pow(10, _asset.exponent);
    final scaledItems = graphItemList.map((item) {
      return AssetGraphItem(
        dto: AssetGraphItemDto(
          timestamp: item.timestamp,
          price: item.price * scaleValue,
        ),
      );
    }).toList();

    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      scaledItems,
      false,
      startDate,
      endDate,
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
    this.isComingSoon,
    this.startDate,
    this.endDate,
  );
  final GraphingDataValue value;
  final Asset asset;
  final List<AssetGraphItem> graphItemList;
  final bool isComingSoon;
  final DateTime startDate;
  final DateTime endDate;
}
