import 'package:json_annotation/json_annotation.dart';

part 'bonded_tokens_dto.g.dart';

@JsonSerializable()
class BondedTokensDto {
  BondedTokensDto({
    this.count,
    this.total,
    this.denom,
  });
  final String? count;
  final String? total;
  final String? denom;

  // ignore: member-ordering
  factory BondedTokensDto.fromJson(Map<String, dynamic> json) =>
      _$BondedTokensDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BondedTokensDtoToJson(this);
}
