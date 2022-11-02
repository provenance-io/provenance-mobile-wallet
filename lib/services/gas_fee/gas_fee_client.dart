import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/gas_price.dart';
import 'package:provenance_wallet/util/strings.dart';

class GasFeeClient {
  Future<GasPrice?> getPrice(Coin coin) {
    throw Strings.notImplementedMessage;
  }
}
