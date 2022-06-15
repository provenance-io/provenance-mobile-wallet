import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_create_request_dto.g.dart';

@JsonSerializable()
class MultiSigCreateRequestDto {
  MultiSigCreateRequestDto({
    required this.name,
    required this.publicKey,
    required this.address,
    required this.numOfAdditionalSigners,
    required this.threshold,
    required this.chainId,
  });

  final String name;
  final String publicKey;
  final String address;
  final int numOfAdditionalSigners;
  final int threshold;
  final String chainId;

  // ignore: member-ordering
  factory MultiSigCreateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreateRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreateRequestDtoToJson(this);
}
