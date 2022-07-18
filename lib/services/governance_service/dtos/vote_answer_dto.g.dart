// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_answer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteAnswerDto _$VoteAnswerDtoFromJson(Map<String, dynamic> json) =>
    VoteAnswerDto(
      VOTE_OPTION_YES: (json['VOTE_OPTION_YES'] as num?)?.toDouble(),
      VOTE_OPTION_ABSTAIN: (json['VOTE_OPTION_ABSTAIN'] as num?)?.toDouble(),
      VOTE_OPTION_NO: (json['VOTE_OPTION_NO'] as num?)?.toDouble(),
      VOTE_OPTION_NO_WITH_VETO:
          (json['VOTE_OPTION_NO_WITH_VETO'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VoteAnswerDtoToJson(VoteAnswerDto instance) =>
    <String, dynamic>{
      'VOTE_OPTION_YES': instance.VOTE_OPTION_YES,
      'VOTE_OPTION_ABSTAIN': instance.VOTE_OPTION_ABSTAIN,
      'VOTE_OPTION_NO': instance.VOTE_OPTION_NO,
      'VOTE_OPTION_NO_WITH_VETO': instance.VOTE_OPTION_NO_WITH_VETO,
    };
