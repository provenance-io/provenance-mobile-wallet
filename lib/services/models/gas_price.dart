///
/// Gas price is amount per unit of denom.
///
class GasPrice {
  GasPrice({
    required this.denom,
    required this.amountPerUnit,
  });

  final String denom;
  final int amountPerUnit;

  @override
  operator ==(Object other) =>
      other is GasPrice &&
      other.denom == denom &&
      other.amountPerUnit == amountPerUnit;

  @override
  int get hashCode => Object.hashAll([denom, amountPerUnit]);

  Map<String, dynamic> toJson() => {
        'denom': denom,
        'amountPerUnit': amountPerUnit,
      };

  static GasPrice fromJson(Map<String, dynamic> json) => GasPrice(
        denom: json['denom'] as String,
        amountPerUnit: json['amountPerUnit'] as int,
      );
}
