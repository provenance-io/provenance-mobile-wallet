import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_pending_tx_dto.g.dart';

@JsonSerializable()
class MultiSigPendingTxDto {
  MultiSigPendingTxDto({
    required this.txUuid,
    required this.txBodyBytes,
  });

  final String txUuid;
  final String txBodyBytes;

  factory MultiSigPendingTxDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigPendingTxDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigPendingTxDtoToJson(this);
}
