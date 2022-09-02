import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_update_tx_request_dto.g.dart';

@JsonSerializable()
class MultiSigUpdateTxRequestDto {
  MultiSigUpdateTxRequestDto({
    required this.txUuid,
    required this.txHash,
  });

  final String txUuid;
  final String txHash;

  factory MultiSigUpdateTxRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigUpdateTxRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigUpdateTxRequestDtoToJson(this);
}
