// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteDto _$VoteDtoFromJson(Map<String, dynamic> json) => VoteDto(
      txHash: json['txHash'] as String?,
      txTimestamp: json['txTimestamp'] == null
          ? null
          : DateTime.parse(json['txTimestamp'] as String),
      proposalId: json['proposalId'] as int?,
      proposalTitle: json['proposalTitle'] as String?,
      proposalStatus: json['proposalStatus'] as String?,
      voter: json['voter'] == null
          ? null
          : ProposerDto.fromJson(json['voter'] as Map<String, dynamic>),
      answer: json['answer'] == null
          ? null
          : VoteAnswerDto.fromJson(json['answer'] as Map<String, dynamic>),
      blockHeight: json['blockHeight'] as int?,
    );

Map<String, dynamic> _$VoteDtoToJson(VoteDto instance) => <String, dynamic>{
      'voter': instance.voter,
      'answer': instance.answer,
      'blockHeight': instance.blockHeight,
      'txHash': instance.txHash,
      'txTimestamp': instance.txTimestamp?.toIso8601String(),
      'proposalId': instance.proposalId,
      'proposalTitle': instance.proposalTitle,
      'proposalStatus': instance.proposalStatus,
    };
