import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_register_request_dto.g.dart';

@JsonSerializable()
class MultiSigRegisterRequestDto {
  MultiSigRegisterRequestDto({
    required this.inviteUuid,
    required this.publicKey,
    required this.address,
  });

  final String inviteUuid;
  final String publicKey;
  final String address;

  // ignore: member-ordering
  factory MultiSigRegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRegisterRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRegisterRequestDtoToJson(this);
}
