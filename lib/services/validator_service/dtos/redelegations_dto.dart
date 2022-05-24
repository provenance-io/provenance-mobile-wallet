import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegation_dto.dart';
import 'package:provenance_wallet/services/validator_service/dtos/delegations_dto.dart';

part 'redelegations_dto.g.dart';

@JsonSerializable()
class RedelegationsDto {
  RedelegationsDto({
    this.records,
    this.rollupTotals,
  });

  final List<DelegationDto>? records;
  final DelegationDto? rollupTotals;

  // ignore: member-ordering
  factory RedelegationsDto.fromJson(Map<String, dynamic> json) =>
      _$RedelegationsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedelegationsDtoToJson(this);
}
