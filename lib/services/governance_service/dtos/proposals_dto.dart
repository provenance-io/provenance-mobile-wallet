import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/proposal_dto.dart';

part 'proposals_dto.g.dart';

@JsonSerializable()
class ProposalsDto {
  ProposalsDto({
    this.pages,
    this.total,
    this.results,
  });

  final int? pages;
  final int? total;
  final List<ProposalDto>? results;

  // ignore: member-ordering
  factory ProposalsDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalsDtoToJson(this);
}
