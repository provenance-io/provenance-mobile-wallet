import 'package:provenance_dart/wallet.dart';

class ChainId {
  static const defaultChainId = mainNet;
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

  static Coin toCoin(String chainId) {
    Coin coin;
    switch (chainId) {
      case ChainId.mainNet:
        coin = Coin.mainNet;
        break;
      case ChainId.testNet:
        coin = Coin.testNet;
        break;
      default:
        throw 'Unsupported chain-id: $chainId';
    }

    return coin;
  }
}
