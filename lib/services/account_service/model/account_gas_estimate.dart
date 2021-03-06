import 'package:decimal/decimal.dart';
import 'package:provenance_dart/proto.dart';

class AccountGasEstimate extends GasEstimate {
  const AccountGasEstimate(
    int estimate,
    this.baseFee, [
    double? feeAdjustment,
    List<Coin>? feeCalculated,
  ]) : super(
          estimate,
          feeAdjustment,
          feeCalculated,
        );

  final int? baseFee;

  @override
  List<Coin>? get feeCalculated {
    final parentFeeCalculated = super.feeCalculated?.toList() ?? <Coin>[];
    parentFeeCalculated.add(Coin(
      denom: "nhash",
      amount: (estimate * (baseFee ?? 0)).toString(),
    ));

    return parentFeeCalculated
        .fold<Map<String, Decimal>>({}, (map, coin) {
          final value = map[coin.denom] ?? Decimal.zero;
          map[coin.denom] = value + Decimal.parse(coin.amount);

          return map;
        })
        .entries
        .map((entry) =>
            Coin(denom: entry.key, amount: entry.value.toBigInt().toString()))
        .toList();
  }

  AccountGasEstimate copyWithBaseFee(int? baseFee) {
    return AccountGasEstimate(
      estimate,
      baseFee,
      feeAdjustment,
      super.feeCalculated,
    );
  }
}
