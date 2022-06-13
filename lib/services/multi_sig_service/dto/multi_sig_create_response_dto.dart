import 'package:json_annotation/json_annotation.dart';

part 'multi_sig_create_response_dto.g.dart';

// {
// 	"name": String,
// 	"walletUuid": UUID,
// 	"inviteLinks": [
// 		String,
// 		String,
// 		String
// 	]
// }

@JsonSerializable()
class MultiSigCreateResponseDto {
  MultiSigCreateResponseDto({
    required this.name,
    required this.walletUuid,
    required this.inviteLinks,
  });

  final String name;
  final String walletUuid;
  final List<String> inviteLinks;

  // ignore: member-ordering
  factory MultiSigCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MultiSigCreateResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MultiSigCreateResponseDtoToJson(this);
}
