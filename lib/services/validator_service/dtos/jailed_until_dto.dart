import 'package:json_annotation/json_annotation.dart';

part 'jailed_until_dto.g.dart';

@JsonSerializable()
class JailedUntilDto {
  JailedUntilDto({
    this.millis,
  });
  final int? millis;

  // ignore: member-ordering
  factory JailedUntilDto.fromJson(Map<String, dynamic> json) =>
      _$JailedUntilDtoFromJson(json);
  Map<String, dynamic> toJson() => _$JailedUntilDtoToJson(this);
}
