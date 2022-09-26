import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/transaction_client/dtos/transaction_dto.dart';

part 'all_transactions_dto.g.dart';

@JsonSerializable()
class AllTransactionsDto {
  AllTransactionsDto({
    this.pages,
    this.totalCount,
    this.transactions,
  });

  final int? pages;
  final int? totalCount;
  final List<TransactionDto>? transactions;

  // ignore: member-ordering
  factory AllTransactionsDto.fromJson(Map<String, dynamic> json) =>
      _$AllTransactionsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AllTransactionsDtoToJson(this);
}
