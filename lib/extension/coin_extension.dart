import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/util/strings.dart';

extension CoinExtension on Coin {
  String get chainId {
    switch (this) {
      case Coin.mainNet:
        return ChainId.mainNet;
      case Coin.testNet:
        return ChainId.testNet;
    }
  }

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
