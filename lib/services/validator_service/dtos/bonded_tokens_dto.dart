import 'package:json_annotation/json_annotation.dart';

part 'bonded_tokens_dto.g.dart';

@JsonSerializable()
class BondedTokensDto {
  BondedTokensDto({
    this.count,
    this.total,
    this.denom,
  });
  final int? count;
  final int? total;
  final String? denom;

  // ignore: member-ordering
  factory BondedTokensDto.fromJson(Map<String, dynamic> json) =>
      _$BondedTokensDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BondedTokensDtoToJson(this);
}
