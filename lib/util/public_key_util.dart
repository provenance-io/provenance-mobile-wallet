import 'package:convert/convert.dart' as convert;
import 'package:provenance_dart/wallet.dart';

PublicKey publicKeyFromCompressedHex(String hex, Coin coin) {
  return PublicKey.fromCompressPublicHex(
    convert.hex.decoder.convert(hex),
    coin,
  );
}
