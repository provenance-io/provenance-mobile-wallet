import 'package:collection/collection.dart';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_wallet/services/models/gas_price.dart';
import 'package:provenance_wallet/util/fee_util.dart';

class GasFeeEstimate {
  GasFeeEstimate(this.units, this.prices)
      : amount = List.unmodifiable(
            combineFees(prices.map((e) => _toCoin(units, e))));

  factory GasFeeEstimate.single({
    required int units,
    required String denom,
    required double amountPerUnit,
  }) =>
      GasFeeEstimate(
        units,
        [
          GasPrice(
            denom: denom,
            amountPerUnit: amountPerUnit,
          ),
        ],
      );

  final int units;
  final List<GasPrice> prices;
  final List<proto.Coin> amount;

  proto.Fee toProtoFee() => proto.Fee(
        gasLimit: proto.Int64(units),
        amount: amount,
      );

  static proto.Coin _toCoin(int units, GasPrice quote) => proto.Coin(
        denom: quote.denom,
        amount: (units * quote.amountPerUnit).ceil().toString(),
      );

  @override
  operator ==(Object other) =>
      other is GasFeeEstimate &&
      other.units == units &&
      ListEquality().equals(other.prices, prices);

  @override
  int get hashCode => Object.hashAll([units, ...prices]);

  Map<String, dynamic> toJson() => {
        'units': units,
        'prices': prices.map((e) => e.toJson()).toList(),
      };

  static GasFeeEstimate fromJson(Map<String, dynamic> json) => GasFeeEstimate(
        json['units'] as int,
        (json['prices'] as List).map((e) => GasPrice.fromJson(e)).toList(),
      );
}
