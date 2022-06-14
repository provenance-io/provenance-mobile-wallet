import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/governance_service/dtos/deposit_dto.dart';

part 'deposits_dto.g.dart';

@JsonSerializable()
class DepositsDto {
  DepositsDto({
    this.pages,
    this.total,
    this.results,
  });

  final int? pages;
  final int? total;
  final List<DepositDto>? results;

  // ignore: member-ordering
  factory DepositsDto.fromJson(Map<String, dynamic> json) =>
      _$DepositsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DepositsDtoToJson(this);
}
