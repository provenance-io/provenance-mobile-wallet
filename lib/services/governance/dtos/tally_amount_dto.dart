import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_client/dtos/balance_dto.dart';

part 'tally_amount_dto.g.dart';

@JsonSerializable()
class TallyAmountDto {
  TallyAmountDto({
    this.count,
    this.amount,
  });

  final int? count;
  final BalanceDto? amount;

  // ignore: member-ordering
  factory TallyAmountDto.fromJson(Map<String, dynamic> json) =>
      _$TallyAmountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TallyAmountDtoToJson(this);
}
