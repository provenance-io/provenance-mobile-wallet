import 'package:json_annotation/json_annotation.dart';

part 'balance_dto.g.dart';

@JsonSerializable()
class BalanceDto {
  BalanceDto({
    this.amount,
    this.denom,
  });
  final String? amount;
  final String? denom;

  // ignore: member-ordering
  factory BalanceDto.fromJson(Map<String, dynamic> json) =>
      _$BalanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceDtoToJson(this);
}
