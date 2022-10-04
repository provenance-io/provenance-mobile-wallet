import 'package:json_annotation/json_annotation.dart';

part 'block_count_dto.g.dart';

@JsonSerializable()
class BlockCountDto {
  BlockCountDto({
    this.count,
    this.total,
  });
  final int? count;
  final int? total;

  // ignore: member-ordering
  factory BlockCountDto.fromJson(Map<String, dynamic> json) =>
      _$BlockCountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BlockCountDtoToJson(this);
}
