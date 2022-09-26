import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/validator_service/dtos/balance_dto.dart';

part 'timings_voting_params_dto.g.dart';

@JsonSerializable()
class TimingsVotingParamsDto {
  TimingsVotingParamsDto({
    this.totalEligibleAmount,
    this.quorumThreshold,
    this.passThreshold,
    this.vetoThreshold,
  });

  final BalanceDto? totalEligibleAmount;
  final String? quorumThreshold;
  final String? passThreshold;
  final String? vetoThreshold;

  // ignore: member-ordering
  factory TimingsVotingParamsDto.fromJson(Map<String, dynamic> json) =>
      _$TimingsVotingParamsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TimingsVotingParamsDtoToJson(this);
}
