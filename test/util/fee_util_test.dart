import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/util/fee_util.dart';

void main() {
  test('Combines fees', () {
    final fees = [
      proto.Coin(denom: 'a', amount: '1'),
      proto.Coin(denom: 'a', amount: '1'),
    ];

    final actual = combineFees(fees);

    expect(
      actual,
      [
        proto.Coin(denom: 'a', amount: '2'),
      ],
    );
  });

  test('Add base fee', () {
    final fees = [
      proto.Coin(denom: 'nhash', amount: '1'),
    ];

    final actual = addBaseFee(1, fees, 1);

    expect(actual, [
      proto.Coin(denom: 'nhash', amount: '2'),
    ]);
  });
}
