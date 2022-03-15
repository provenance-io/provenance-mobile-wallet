import 'package:provenance_dart/wallet.dart' as wallet;

extension CoinHelper on wallet.Coin {
  String get chainId {
    switch (this) {
      case wallet.Coin.mainNet:
        return "pio-mainnet-1";
      case wallet.Coin.testNet:
        return "pio-testnet-1";
    }
  }

  String get address {
    switch (this) {
      case wallet.Coin.mainNet:
        return "grpc://34.148.39.82:9090";
      case wallet.Coin.testNet:
        return "grpc://34.148.50.57:9090";
    }
  }
}
