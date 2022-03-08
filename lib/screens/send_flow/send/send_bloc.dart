import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
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
    this._provenanceAddress,
    this._assetService,
    this._transactionService,
    this._navigator,
  );

  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
  final _stateStreamController = StreamController<SendBlocState>();
  final String _provenanceAddress;
  final SendBlocNavigator _navigator;
  final AssetService _assetService;
  final TransactionService _transactionService;

  Stream<SendBlocState> get stream => _stateStreamController.stream;

  Future<void> load() {
    return Future.wait([
      _assetService.getAssets(_provenanceAddress),
      _transactionService.getTransactions(_provenanceAddress),
    ]).then((results) {
      final assetResponse = results[0] as List<Asset>;
      final transResponse = results[1] as List<Transaction>;

      final assets = assetResponse.map((asset) {
        return SendAsset(
          asset.display,
          asset.exponent,
          asset.denom,
          Decimal.parse(asset.amount),
          "0",
          "",
        );
      });

      final recentAddresses = transResponse.map((trans) {
        final timeStamp = trans.timestamp;

        return RecentAddress(trans.recipientAddress, timeStamp);
      });

      final state = SendBlocState(
        assets.toList(),
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
