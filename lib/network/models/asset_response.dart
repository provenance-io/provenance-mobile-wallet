import 'package:json_annotation/json_annotation.dart';

part 'asset_response.g.dart';

@JsonSerializable()
class AssetResponse {
  AssetResponse({
    required this.denom,
    required this.amount,
    required this.display,
    required this.description,
    required this.exponent,
    required this.displayAmount,
  });

  final String? denom;
  final String? amount;
  final String? display;
  final String? description;
  final int? exponent;
  final String? displayAmount;

  // ignore: member-ordering
  factory AssetResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AssetResponseToJson(this);
}
