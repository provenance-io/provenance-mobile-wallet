// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'votes_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VotesDto _$VotesDtoFromJson(Map<String, dynamic> json) => VotesDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => VoteDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VotesDtoToJson(VotesDto instance) => <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
    };
