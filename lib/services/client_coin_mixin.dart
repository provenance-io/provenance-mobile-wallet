import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/util/get.dart';

mixin ClientCoinMixin on Object {
  HttpClient getClient(Coin coin) {
    switch (coin) {
      case Coin.mainNet:
        return get<MainHttpClient>();
      case Coin.testNet:
        return get<TestHttpClient>();
    }
  }
}
