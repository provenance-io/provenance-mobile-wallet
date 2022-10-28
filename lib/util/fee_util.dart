import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';

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

proto.Fee toFee(AccountGasEstimate estimate) => proto.Fee(
      amount: estimate.totalFees,
      gasLimit: proto.Int64(estimate.estimatedGas),
    );
