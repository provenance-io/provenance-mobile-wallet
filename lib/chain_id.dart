import 'package:provenance_dart/wallet.dart';

class ChainId {
  static const mainNet = 'pio-mainnet-1';
  static const testNet = 'pio-testnet-1';

  static String forCoin(Coin coin) {
    switch (coin) {
      case Coin.mainNet:
        return ChainId.mainNet;
      case Coin.testNet:
        return ChainId.testNet;
    }
  }
}
