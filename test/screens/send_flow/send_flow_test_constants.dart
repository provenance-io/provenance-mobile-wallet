import 'package:decimal/decimal.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/gas_fee_estimate.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';
import 'package:provenance_wallet/services/models/account.dart';

final publicKey = PrivateKey.fromSeed(
  Mnemonic.createSeed(['one']),
  Coin.testNet,
).defaultKey().publicKey;

final walletDetails = BasicAccount(
  publicKey: publicKey,
  id: "1",
  name: "Wallet1",
);

final hashAsset = SendAsset(
  "Hash",
  2,
  "nhash",
  Decimal.fromInt(130),
  111,
);
final dollarAsset = SendAsset(
  "USD",
  2,
  "USD",
  Decimal.fromInt(1),
  2,
);
final feeAsset = MultiSendAsset(
  GasFeeEstimate(2, []),
  [
    SendAsset(
      "Hash",
      22,
      "nhash",
      Decimal.fromInt(9),
      0,
    ),
    SendAsset(
      "USD",
      1,
      "USD",
      Decimal.fromInt(1),
      0,
    ),
  ],
);
