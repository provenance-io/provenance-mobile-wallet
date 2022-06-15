import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_signer_dto.g.dart';

@JsonSerializable()
class MultiSigSignerDto {
  MultiSigSignerDto({
    required this.signerUuid,
    required this.inviteUuid,
    required this.originalSigner,
    this.publicKey,
    this.address,
    this.redeemDate,
  });

  final String signerUuid;
  final String inviteUuid;
  final bool originalSigner;
  final String? publicKey;
  final String? address;
  final String? redeemDate;

  // ignore: member-ordering
  factory MultiSigSignerDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigSignerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigSignerDtoToJson(this);
}
