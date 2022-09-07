import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_pending_tx_request_dto.g.dart';

@JsonSerializable()
class MultiSigPendingTxRequestDto {
  MultiSigPendingTxRequestDto({
    required this.addresses,
  });

  final List<String> addresses;

  factory MultiSigPendingTxRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigPendingTxRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigPendingTxRequestDtoToJson(this);
}
