import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

abstract class SendBlocNavigator {
  Future<String?> scanAddress();

  Future<void> showSelectAmount(String address, SendAsset asset);

  Future<void> showAllRecentSends();
}

class RecentAddress {
  RecentAddress(this.address, this.lastSend);

  final String address;
  final DateTime lastSend;
}

class SendBlocState {
  SendBlocState(this.availableAssets, this.recentSendAddresses);

  final List<SendAsset> availableAssets;

  final List<RecentAddress> recentSendAddresses;
}

class SendBloc extends Disposable {
  SendBloc(
    this._coin,
    this._provenanceAddress,
    this._assetService,
    this._priceService,
    this._transactionService,
    this._navigator,
  );

  final _stateStreamController = StreamController<SendBlocState>();
  final Coin _coin;
  final String _provenanceAddress;
  final SendBlocNavigator _navigator;
  final AssetService _assetService;
  final TransactionService _transactionService;
  final PriceService _priceService;

  Stream<SendBlocState> get stream => _stateStreamController.stream;

  Future<void> load() {
    final assetFuture =
        _assetService.getAssets(_coin, _provenanceAddress).then((assets) async {
      final denominations = assets.map((e) => e.denom).toSet().toList();

      final prices = await _priceService
          .getAssetPrices(_coin, denominations)
          .then((response) {
        final map = <String, double>{};
        for (var price in response) {
          map[price.denomination] = price.usdPrice;
        }

        return map;
      });

      return assets.map((asset) {
        final price = prices[asset.denom] ?? 0.0;

        return SendAsset(
          asset.display,
          asset.exponent,
          asset.denom,
          Decimal.parse(asset.amount),
          price,
          asset.image,
        );
      }).toList();
    });

    return Future.wait([
      assetFuture,
      _transactionService.getTransactions(
        _coin,
        _provenanceAddress,
        1,
      ),
    ]).then((results) {
      final assetResponse = results[0] as List<SendAsset>;
      final transResponse = results[1] as List<Transaction>;

      final recentAddresses =
          transResponse.distinctBy((e) => e.signer).take(5).map((trans) {
        final timeStamp = trans.time;

        return RecentAddress(trans.signer, timeStamp);
      });

      final state = SendBlocState(
        assetResponse.toList(),
        recentAddresses.toList(),
      );
      _stateStreamController.add(state);
    });
  }

  @override
  FutureOr onDispose() {
    _stateStreamController.close();
  }

  void showAllRecentSends() {
    _navigator.showAllRecentSends();
  }

  Future<String?> scanAddress() async {
    return _navigator.scanAddress();
  }

  Future<void> next(String address, SendAsset? asset) {
    if (address.isEmpty) {
      throw Exception("You must supply a receiving address");
    }
    if (asset == null) {
      throw Exception("You must supply an asset");
    }

    return _navigator.showSelectAmount(address, asset);
  }
}
