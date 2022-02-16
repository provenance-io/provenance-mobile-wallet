import 'package:json_annotation/json_annotation.dart';

part 'transaction_dto.g.dart';

@JsonSerializable()
class TransactionDto {
  TransactionDto({
    this.address,
    this.feeAmount,
    this.id,
    this.signer,
    this.status,
    this.time,
    this.type,
  });

  final String? address;
  final String? feeAmount;
  final String? id;
  final String? signer;
  final String? status;
  final String? time;
  final String? type;

  // ignore: member-ordering
  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);
}
