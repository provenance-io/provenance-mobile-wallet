import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/proposal_dto.dart';

part 'proposals_dto.g.dart';

@JsonSerializable()
class ProposalssDto {
  ProposalssDto({
    this.pages,
    this.total,
    this.results,
  });

  final int? pages;
  final int? total;
  final List<ProposalDto>? results;

  // ignore: member-ordering
  factory ProposalssDto.fromJson(Map<String, dynamic> json) =>
      _$ProposalssDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalssDtoToJson(this);
}
