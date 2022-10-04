import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance/dtos/vote_dto.dart';

part 'votes_dto.g.dart';

@JsonSerializable()
class VotesDto {
  VotesDto({
    this.pages,
    this.total,
    this.results,
  });

  final int? pages;
  final int? total;
  final List<VoteDto>? results;

  // ignore: member-ordering
  factory VotesDto.fromJson(Map<String, dynamic> json) =>
      _$VotesDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VotesDtoToJson(this);
}
