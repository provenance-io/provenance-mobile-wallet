import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/extension/list_extension.dart';

List<proto.Coin> combineFees(Iterable<proto.Coin> fees) {
  final list = fees
      .fold<Map<String, Decimal>>({}, (map, coin) {
        final value = map[coin.denom] ?? Decimal.zero;
        map[coin.denom] = value + Decimal.parse(coin.amount);

        return map;
      })
      .entries
      .map((entry) => proto.Coin(
          denom: entry.key, amount: entry.value.toBigInt().toString()))
      .toList();

  list.sortAscendingBy((e) => e.denom);

  return list;
}

List<proto.Coin> addBaseFee(
    int gasUnits, List<proto.Coin>? estimatedFees, int? gasFeePerUnit) {
  final result = <proto.Coin>[
    proto.Coin(
      denom: 'nhash',
      amount: (gasUnits * (gasFeePerUnit ?? 0)).toString(),
    ),
    ...estimatedFees ?? [],
  ];

  return combineFees(result);
}
