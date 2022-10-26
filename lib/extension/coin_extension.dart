import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/util/strings.dart';

const defaultCoin = Coin.mainNet;

extension CoinExtension on Coin {
  String get displayName {
    String result;
    switch (this) {
      case Coin.mainNet:
        result = Strings.chainMainNetName;
        break;
      case Coin.testNet:
        result = Strings.chainTestNetName;
        break;
    }

    return result;
  }
}
