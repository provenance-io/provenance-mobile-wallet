import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_create_tx_response_dto.g.dart';

@JsonSerializable()
class MultiSigCreateTxResponseDto {
  MultiSigCreateTxResponseDto({
    required this.txUuid,
  });

  final String txUuid;

  factory MultiSigCreateTxResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreateTxResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreateTxResponseDtoToJson(this);
}
