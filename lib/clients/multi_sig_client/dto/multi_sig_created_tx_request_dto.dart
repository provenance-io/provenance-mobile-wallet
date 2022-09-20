import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';

part 'multi_sig_created_tx_request_dto.g.dart';

@JsonSerializable()
class MultiSigCreatedTxRequestDto {
  MultiSigCreatedTxRequestDto({
    required this.addresses,
    this.status,
  });

  final List<String> addresses;
  final MultiSigStatus? status;

  factory MultiSigCreatedTxRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreatedTxRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreatedTxRequestDtoToJson(this);
}
