// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_transactions_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllTransactionsDto _$AllTransactionsDtoFromJson(Map<String, dynamic> json) =>
    AllTransactionsDto(
      pages: json['pages'] as int?,
      totalCount: json['totalCount'] as int?,
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllTransactionsDtoToJson(AllTransactionsDto instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'totalCount': instance.totalCount,
      'transactions': instance.transactions,
    };
