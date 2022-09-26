import 'package:json_annotation/json_annotation.dart';

part 'transaction_dto.g.dart';

@JsonSerializable()
class TransactionDto {
  TransactionDto({
    this.block,
    this.feeAmount,
    this.hash,
    this.signer,
    this.status,
    this.time,
    this.type,
    this.denom,
  });

  final int? block;
  final String? feeAmount;
  final String? hash;
  final String? signer;
  final String? status;
  final DateTime? time;
  final String? type;
  final String? denom;

  // ignore: member-ordering
  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);
}
