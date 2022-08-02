import 'package:json_annotation/json_annotation.dart';

part 'proposer_dto.g.dart';

@JsonSerializable()
class ProposerDto {
  ProposerDto({
    this.address,
    this.validatorAddr,
    this.moniker,
  });

  final String? address;
  final String? validatorAddr;
  final String? moniker;

  // ignore: member-ordering
  factory ProposerDto.fromJson(Map<String, dynamic> json) =>
      _$ProposerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProposerDtoToJson(this);
}
