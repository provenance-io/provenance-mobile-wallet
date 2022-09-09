import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_signer_dto.g.dart';

@JsonSerializable()
class MultiSigSignerDto {
  MultiSigSignerDto({
    required this.inviteUuid,
    required this.signerUuid,
    required this.signerOrder,
    this.address,
    this.publicKey,
    this.redeemDate,
  });

  final String inviteUuid;
  final String signerUuid;
  final int signerOrder;

  final String? address;
  final String? publicKey;
  final String? redeemDate;

  // ignore: member-ordering
  factory MultiSigSignerDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigSignerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigSignerDtoToJson(this);
}
