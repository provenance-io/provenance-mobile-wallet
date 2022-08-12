import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart' as proto;

List<proto.Coin> combineFees(List<proto.Coin> fees) {
  return fees
      .fold<Map<String, Decimal>>({}, (map, coin) {
        final value = map[coin.denom] ?? Decimal.zero;
        map[coin.denom] = value + Decimal.parse(coin.amount);

        return map;
      })
      .entries
      .map((entry) => proto.Coin(
          denom: entry.key, amount: entry.value.toBigInt().toString()))
      .toList();
}

List<proto.Coin> addBaseFee(
    int estimatedGas, List<proto.Coin>? estimatedFees, int? baseFee) {
  final result = <proto.Coin>[
    proto.Coin(
      denom: 'nhash',
      amount: (estimatedGas * (baseFee ?? 0)).toString(),
    ),
    ...estimatedFees ?? [],
  ];

  return combineFees(result);
}
