import 'package:provenance_dart/wallet.dart' as wallet;

extension CoinHelper on wallet.Coin {
  String get chainId {
    switch(this) {
      case wallet.Coin.mainNet: return "pio-mainnet-1";
      case wallet.Coin.testNet: return "pio-testnet-1";
    }
  }

  String get address {
    switch(this) {
      case wallet.Coin.mainNet: return "grpcs://grpc.provenance.io:443";
      case wallet.Coin.testNet: return "grpcs://grpc.test.provenance.io:443";
    }
  }
}
