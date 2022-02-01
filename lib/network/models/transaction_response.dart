import 'package:json_annotation/json_annotation.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  TransactionResponse({
    required this.address,
    required this.feeAmount,
    required this.id,
    required this.signer,
    required this.status,
    required this.time,
    required this.type,
  });

  final String? address;
  final String? feeAmount;
  final String? id;
  final String? signer;
  final String? status;
  final String? time;
  final String? type;

  // ignore: member-ordering
  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionResponseToJson(this);
}
