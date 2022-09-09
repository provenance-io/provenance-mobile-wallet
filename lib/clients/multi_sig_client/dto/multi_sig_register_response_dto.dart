import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_register_response_dto.g.dart';

@JsonSerializable()
class MultiSigRegisterResponseDto {
  MultiSigRegisterResponseDto({
    required this.address,
    required this.inviteUuid,
    required this.publicKey,
    required this.redeemDate,
    required this.signerOrder,
    required this.signerUuid,
  });

  final String address;
  final String inviteUuid;
  final String publicKey;
  final String redeemDate;
  final int signerOrder;
  final String signerUuid;

  // ignore: member-ordering
  factory MultiSigRegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRegisterResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRegisterResponseDtoToJson(this);
}
