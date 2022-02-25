import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:rational/rational.dart';

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
  SendBloc(this._provenanceAddress, this._assetService, this._transactionService, this._navigator,);

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
    ])
    .then((results) {
      final assetResponse = results[0] as BaseResponse<List<Asset>>;
      final transResponse = results[1] as BaseResponse<List<Transaction>>;

      final assets = assetResponse.data?.map((asset) {
        return SendAsset(asset.display, asset.exponent, asset.denom, Decimal.parse(asset.amount), "0", "",);
      });
      
      final recentAddresses = transResponse.data?.map((trans) {
        final timeStamp = _dateFormat.parse(trans.time);

        return RecentAddress(trans.address, timeStamp);
      });

      final state = SendBlocState(
        assets?.toList() ?? <SendAsset>[], 
        recentAddresses?.toList() ?? <RecentAddress>[],
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
    if(address.isEmpty) {
      throw Exception("You must supply a receiving address");
    }
    if(asset == null) {
      throw Exception("You must supply an asset");
    }

    return _navigator.showSelectAmount(address, asset);
  }
}