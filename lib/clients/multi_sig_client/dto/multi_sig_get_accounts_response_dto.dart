import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_signer_dto.dart';

part 'multi_sig_get_accounts_response_dto.g.dart';

@JsonSerializable()
class MultiSigGetAccountsResponseDto {
  MultiSigGetAccountsResponseDto({
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
  factory MultiSigGetAccountsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigGetAccountsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigGetAccountsResponseDtoToJson(this);
}
