import 'dart:async';

import 'package:get_it/get_it.dart';

abstract class SendBlocNavigator {
  Future<String?> scanAddress();

  Future<void> showSelectAmount(String address, String denom);

  Future<void> showAllRecentSends();

  Future<void> showRecentSendDetails(RecentAddress recentAddress);
}

class Asset {
  Asset(this.denom, this.amount, this.fiatValue, this.imageUrl);

  final String denom;
  final String amount;
  final String fiatValue;
  final String imageUrl;
}

class RecentAddress {
  RecentAddress(this.address, this.lastSend);

  final String address;
  final DateTime lastSend;
}

class SendBlocState {
  SendBlocState(this.availableAssets, this.recentSendAddresses);

  final List<Asset> availableAssets;

  final List<RecentAddress> recentSendAddresses;
}

class SendBloc extends Disposable {
  SendBloc(this._navigator);

  final SendBlocNavigator _navigator;
  final _stateStreamController = StreamController<SendBlocState>();

  Stream<SendBlocState> get stream => _stateStreamController.stream;

  Future<void> load() {
    return Future.delayed(
        Duration(milliseconds: 600),
        () {
          final assets = [
            Asset("Hash", "302.02", "\$523.25", "https://raw.githubusercontent.com/osmosis-labs/assetlists/main/images/hash.png"),
            Asset("USD", "51.15", "\$51.15", "https://cryptologos.cc/logos/usd-coin-usdc-logo.png?v=021"),
          ];

          final sends = List.generate(15, (index) {
            return RecentAddress(
              "tp1n38hkvvq4zfkagmd37dt68llff0vksjy620j6u",
              DateTime.now().subtract(Duration(days: index)),
            );
          })
          .toList();

          _stateStreamController.add(SendBlocState(assets, sends));
        },
    );
  }

  @override
  FutureOr onDispose() {
    _stateStreamController.close();
  }

  void showAllRecentSends() {
    _navigator.showAllRecentSends();
  }

  void showRecentSendDetails(RecentAddress recentAddress) {
    _navigator.showRecentSendDetails(recentAddress);
  }

  Future<String?> scanAddress() async {
    return _navigator.scanAddress();
  }

  Future<void> next(String address, String denom) {
    if(address.isEmpty) {
      throw Exception("You must supply a receiving address");
    }
    if(denom.isEmpty) {
      throw Exception("You must supply a receiving denomination");
    }

    return _navigator.showSelectAmount(address, denom);
  }
}