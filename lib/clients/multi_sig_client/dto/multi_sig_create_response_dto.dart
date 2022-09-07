import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_signer_dto.dart';

part 'multi_sig_create_response_dto.g.dart';

@JsonSerializable()
class MultiSigCreateResponseDto {
  MultiSigCreateResponseDto({
    required this.chainId,
    required this.name,
    required this.signers,
    required this.status,
    required this.threshold,
    required this.walletUuid,
  });

  final String chainId;
  final String name;

  final List<MultiSigSignerDto> signers;
  final String status;
  final int threshold;
  final String walletUuid;

  // ignore: member-ordering
  factory MultiSigCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreateResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreateResponseDtoToJson(this);
}
