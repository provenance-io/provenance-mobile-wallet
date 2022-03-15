import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/screens/send_flow/model/send_asset.dart';

void main() {
  group("SendAsset", () {
    test("displayAmount", () {
      var asset = SendAsset(
        "hash",
        9,
        "nhash",
        Decimal.fromInt(1000000001),
        "754.33",
        "AA",
      );

      expect(asset.displayAmount, "1.000000001");

      asset = SendAsset(
        "hash",
        1,
        "nhash",
        Decimal.fromInt(1000000001),
        "754.33",
        "AA",
      );

      expect(asset.displayAmount, "100000000.1");
    });

    test("copyWith", () {
      var asset = SendAsset(
        "hash",
        9,
        "nhash",
        Decimal.fromInt(1000000001),
        "754.33",
        "AA",
      );
      var copy = asset.copyWith(amount: Decimal.fromInt(500));

      expect(copy.amount, Decimal.fromInt(500));
      expect(copy.denom, asset.denom);
      expect(copy.displayDenom, asset.displayDenom);
      expect(copy.exponent, asset.exponent);
      expect(copy.fiatValue, asset.fiatValue);
    });
  });

  group("MultiSendAsset", () {
    test("displayAmount", () {
      final asset = MultiSendAsset(100, [
        SendAsset(
          "Hash",
          9,
          "nhash",
          Decimal.fromInt(20000),
          "",
          "",
        ),
        SendAsset(
          "Usd",
          2,
          "usd",
          Decimal.fromInt(20000),
          "",
          "",
        ),
        SendAsset(
          "Hash",
          9,
          "nhash",
          Decimal.fromInt(200),
          "",
          "",
        ),
      ]);

      expect(asset.displayAmount, "0.0000202 Hash + 200 Usd");
    });
  });
}
