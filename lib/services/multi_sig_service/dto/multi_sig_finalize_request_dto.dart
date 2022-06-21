import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_finalize_request_dto.g.dart';

@JsonSerializable()
class MultiSigFinalizeRequestDto {
  MultiSigFinalizeRequestDto({
    required this.walletUuid,
    required this.publicKey,
  });

  final String walletUuid;
  final String publicKey;

  // ignore: member-ordering
  factory MultiSigFinalizeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigFinalizeRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigFinalizeRequestDtoToJson(this);
}
