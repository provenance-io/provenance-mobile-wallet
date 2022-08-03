import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/proposer_dto.dart';

part 'header_dto.g.dart';

@JsonSerializable()
class HeaderDto {
  HeaderDto({
    this.proposalId,
    this.status,
    this.proposer,
    this.type,
    this.title,
    this.description,
  });

  final int? proposalId;
  final String? status;
  final ProposerDto? proposer;
  final String? type;
  final String? title;
  final String? description;

  // ignore: member-ordering
  factory HeaderDto.fromJson(Map<String, dynamic> json) =>
      _$HeaderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$HeaderDtoToJson(this);
}
