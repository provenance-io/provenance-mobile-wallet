// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timings_voting_params_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimingsVotingParamsDto _$TimingsVotingParamsDtoFromJson(
        Map<String, dynamic> json) =>
    TimingsVotingParamsDto(
      totalEligibleAmount: json['totalEligibleAmount'] == null
          ? null
          : BalanceDto.fromJson(
              json['totalEligibleAmount'] as Map<String, dynamic>),
      quorumThreshold: json['quorumThreshold'] as String?,
      passThreshold: json['passThreshold'] as String?,
      vetoThreshold: json['vetoThreshold'] as String?,
    );

Map<String, dynamic> _$TimingsVotingParamsDtoToJson(
        TimingsVotingParamsDto instance) =>
    <String, dynamic>{
      'totalEligibleAmount': instance.totalEligibleAmount,
      'quorumThreshold': instance.quorumThreshold,
      'passThreshold': instance.passThreshold,
      'vetoThreshold': instance.vetoThreshold,
    };
