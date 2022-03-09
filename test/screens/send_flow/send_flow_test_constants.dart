import 'package:decimal/decimal.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';

final walletDetails = WalletDetails(
  address: "tp1g5ugfegkl5gmn049n5a9hgjn3ged0ekp8f2fwx",
  coin: Coin.testNet,
  publicKey:
      "02da92ecc44eef3299e00cdf8f4768d5b606bf8242ff5277e6f07aadd935257a37",
  id: "1",
  name: "Wallet1",
);

final hashAsset = SendAsset(
  "Hash",
  2,
  "nHash",
  Decimal.fromInt(130),
  "111",
  "http://test.com",
);
final dollarAsset = SendAsset(
  "USD",
  2,
  "USD",
  Decimal.fromInt(1),
  "2",
  "http://test1.com",
);
final feeAsset = MultiSendAsset(
  SendAsset(
    "Hash",
    2,
    "nHash",
    Decimal.fromInt(9),
    "",
    "",
  ),
  [
    SendAsset(
      "USD",
      1,
      "USD",
      Decimal.fromInt(1),
      "",
      "hm",
    ),
    SendAsset(
      "Hash",
      22,
      "nHash",
      Decimal.fromInt(9),
      "",
      "",
    ),
  ],
);
