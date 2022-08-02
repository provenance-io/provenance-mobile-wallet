// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tally_amount_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TallyAmountDto _$TallyAmountDtoFromJson(Map<String, dynamic> json) =>
    TallyAmountDto(
      count: json['count'] as int?,
      amount: json['amount'] == null
          ? null
          : BalanceDto.fromJson(json['amount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TallyAmountDtoToJson(TallyAmountDto instance) =>
    <String, dynamic>{
      'count': instance.count,
      'amount': instance.amount,
    };
