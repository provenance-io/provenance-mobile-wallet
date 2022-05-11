import 'package:json_annotation/json_annotation.dart';

part 'integration_test_data.g.dart';

@JsonSerializable()
class IntegrationTestData {
  const IntegrationTestData({
    this.recoverWalletTest,
  });

  final RecoverWalletTestData? recoverWalletTest;

  // ignore: member-ordering
  factory IntegrationTestData.fromJson(Map<String, dynamic> json) =>
      _$IntegrationTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationTestDataToJson(this);
}

@JsonSerializable()
class RecoverWalletTestData {
  const RecoverWalletTestData({
    this.recoveryPhrase,
  });

  final String? recoveryPhrase;

  // ignore: member-ordering
  factory RecoverWalletTestData.fromJson(Map<String, dynamic> json) =>
      _$RecoverWalletTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$RecoverWalletTestDataToJson(this);
}
