import 'package:json_annotation/json_annotation.dart';

part 'transaction_dto.g.dart';

@JsonSerializable()
class TransactionDto {
  TransactionDto({
    this.amount,
    this.block,
    this.denom,
    this.hash,
    this.recipientAddress,
    this.senderAddress,
    this.status,
    this.timestamp,
    this.txFee,
    this.pricePerUnit,
    this.totalPrice,
    this.exponent,
  });

  final int? amount;
  final int? block;
  final String? denom;
  final String? hash;
  final String? recipientAddress;
  final String? senderAddress;
  final String? status;
  final DateTime? timestamp;
  final int? txFee;
  final double? pricePerUnit;
  final double? totalPrice;
  final int? exponent;

  // ignore: member-ordering
  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);
}
