// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'vote_answer_dto.g.dart';

@JsonSerializable()
class VoteAnswerDto {
  VoteAnswerDto({
    this.VOTE_OPTION_YES,
    this.VOTE_OPTION_ABSTAIN,
    this.VOTE_OPTION_NO,
    this.VOTE_OPTION_NO_WITH_VETO,
  });

  final double? VOTE_OPTION_YES;
  final double? VOTE_OPTION_ABSTAIN;
  final double? VOTE_OPTION_NO;
  final double? VOTE_OPTION_NO_WITH_VETO;

  // ignore: member-ordering
  factory VoteAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$VoteAnswerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VoteAnswerDtoToJson(this);
}
