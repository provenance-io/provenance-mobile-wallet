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
    // this.type,
  });

  @JsonKey(name: "recipientAddress")
  final String? address;
  @JsonKey(name: "txFee")
  final int? feeAmount;
  @JsonKey(name: "hash")
  final String? id;
  @JsonKey(name: "senderAddress")
  final String? signer;
  final String? status;
  @JsonKey(name: "timestamp")
  final String? time;
  final String? type = "SEND";

  // ignore: member-ordering
  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);
}
