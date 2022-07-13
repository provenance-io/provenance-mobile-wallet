import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/services/multi_sig_service/dto/multi_sig_signer_dto.dart';

part 'multi_sig_get_account_by_invite_response_dto.g.dart';

@JsonSerializable()
class MultiSigGetAccountByInviteResponseDto {
  MultiSigGetAccountByInviteResponseDto({
    required this.name,
    required this.walletUuid,
    required this.threshold,
    required this.status,
    required this.chainId,
    required this.signers,
    this.publicKey,
    this.address,
  });

  final String name;
  final String walletUuid;
  final int threshold;
  final String status;
  final String chainId;
  List<MultiSigSignerDto> signers;
  final String? publicKey;
  final String? address;

  // ignore: member-ordering
  factory MultiSigGetAccountByInviteResponseDto.fromJson(
          Map<String, dynamic> json) =>
      _$MultiSigGetAccountByInviteResponseDtoFromJson(json);
  Map<String, dynamic> toJson() =>
      _$MultiSigGetAccountByInviteResponseDtoToJson(this);
}
