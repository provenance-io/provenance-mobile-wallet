import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_register_response_dto.g.dart';

@JsonSerializable()
class MultiSigRegisterResponseDto {
  MultiSigRegisterResponseDto({
    required this.name,
    required this.walletUuid,
    required this.inviteLinks,
  });

  final String name;
  final String walletUuid;
  final List<String> inviteLinks;

  // ignore: member-ordering
  factory MultiSigRegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigRegisterResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigRegisterResponseDtoToJson(this);
}
