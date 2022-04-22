import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
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
    GraphingDataValue value = GraphingDataValue.hourly,
  }) async {
    // change the datapoint scale so that tooltips on the chart are smoother
    GraphingDataValue modifiedDataValue = value;
    final endDate = DateTime.now();
    DateTime? startDate;

    switch (value) {
      case GraphingDataValue.hourly:
        startDate = endDate.subtract(Duration(hours: 24));
        modifiedDataValue = GraphingDataValue.hourly;
        break;
      case GraphingDataValue.daily:
        startDate = endDate.subtract(Duration(days: 7));
        modifiedDataValue = GraphingDataValue.hourly;
        break;
      case GraphingDataValue.weekly:
        startDate = endDate.subtract(Duration(days: 4 * 7));
        modifiedDataValue = GraphingDataValue.daily;
        break;
      case GraphingDataValue.monthly:
        startDate = DateTime(
          endDate.year - 1,
          endDate.month,
          endDate.day,
          endDate.hour,
          endDate.minute,
          endDate.second,
          endDate.millisecond,
          endDate.microsecond,
        );
        modifiedDataValue = GraphingDataValue.weekly;
        break;
      case GraphingDataValue.yearly:
        startDate = DateTime(
          endDate.year - 4,
          endDate.month,
          endDate.day,
          endDate.hour,
          endDate.minute,
          endDate.second,
          endDate.millisecond,
          endDate.microsecond,
        );
        modifiedDataValue = GraphingDataValue.monthly;
        break;
      default:
      // no specific start date.
    }

    _chartDetails.value = AssetChartDetails(
      value,
      _asset,
      [],
      false,
    );

    final graphItemList = await _assetService.getAssetGraphingData(
      _coin,
      _asset.denom,
      modifiedDataValue,
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
      true,
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
    this.isLoadingFinished,
  );
  final GraphingDataValue value;
  final Asset asset;
  final List<AssetGraphItem> graphItemList;
  final bool isLoadingFinished;
}
