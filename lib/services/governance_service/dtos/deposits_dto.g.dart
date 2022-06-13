// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposits_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositsDto _$DepositsDtoFromJson(Map<String, dynamic> json) => DepositsDto(
      pages: json['pages'] as int?,
      total: json['total'] as int?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => DepositDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DepositsDtoToJson(DepositsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'total': instance.total,
      'results': instance.results,
    };
