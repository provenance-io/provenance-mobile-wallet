import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/models/send_transactions.dart';
import 'package:provenance_wallet/services/price_client/price_service.dart';
import 'package:provenance_wallet/services/transaction_client/transaction_client.dart';
import 'package:provenance_wallet/util/extensions/iterable_extensions.dart';

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
    this._assetClient,
    this._priceClient,
    this._transactionClient,
    this._navigator,
  );

  final _stateStreamController = StreamController<SendBlocState>();
  final Coin _coin;
  final String _provenanceAddress;
  final SendBlocNavigator _navigator;
  final AssetClient _assetClient;
  final TransactionClient _transactionClient;
  final PriceClient _priceClient;

  Stream<SendBlocState> get stream => _stateStreamController.stream;

  Future<void> load() {
    final assetFuture =
        _assetClient.getAssets(_coin, _provenanceAddress).then((assets) async {
      final denominations = assets.map((e) => e.denom).toSet().toList();

      final prices = await _priceClient
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
        );
      }).toList();
    });

    return Future.wait([
      assetFuture,
      _transactionClient.getSendTransactions(
        _coin,
        _provenanceAddress,
      ),
    ]).then((results) {
      final assetResponse = results[0] as List<SendAsset>;
      final transResponse = results[1] as List<SendTransaction>;

      final recentAddresses = transResponse
          .distinctBy((e) => e.recipientAddress)
          .take(5)
          .map((trans) {
        final timeStamp = trans.timestamp;

        return RecentAddress(trans.recipientAddress, timeStamp);
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
