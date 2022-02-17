import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';

abstract class SendBlocNavigator {
  Future<String?> scanAddress();

  Future<void> showSelectAmount(String address, SendAsset asset);

  Future<void> showAllRecentSends();

  Future<void> showRecentSendDetails(RecentAddress recentAddress);
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
  SendBloc(this._navigator);

  final SendBlocNavigator _navigator;
  final _stateStreamController = StreamController<SendBlocState>();

  Stream<SendBlocState> get stream => _stateStreamController.stream;

  Future<void> load() {
    return Future.delayed(
        Duration(milliseconds: 600),
        () {
          final assets = [
            SendAsset("Hash", "302.02", "\$523.25", "https://raw.githubusercontent.com/osmosis-labs/assetlists/main/images/hash.png"),
            SendAsset("USD", "51.15", "\$51.15", "https://cryptologos.cc/logos/usd-coin-usdc-logo.png?v=021"),
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