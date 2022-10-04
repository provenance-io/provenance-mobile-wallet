import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance/dtos/header_dto.dart';
import 'package:provenance_wallet/services/governance/dtos/timings_dto.dart';

part 'proposal_dto.g.dart';

@JsonSerializable()
class ProposalDto {
  ProposalDto({
    this.header,
    this.timings,
  });

  final HeaderDto? header;
  final TimingsDto? timings;

  // ignore: member-ordering
  factory ProposalDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalDtoToJson(this);
}
