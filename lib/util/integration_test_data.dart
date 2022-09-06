import 'package:json_annotation/json_annotation.dart';

part 'integration_test_data.g.dart';

@JsonSerializable()
class IntegrationTestData {
  const IntegrationTestData({
    this.recoveryPhrase,
    this.accountName,
    this.cipherPin,
    this.switchAccountsTest,
    this.sendHashTest,
  });
  final String? recoveryPhrase;
  final String? accountName;
  final String? cipherPin;

  final SwitchAccountsTestData? switchAccountsTest;
  final SendHashTestData? sendHashTest;

  // ignore: member-ordering
  factory IntegrationTestData.fromJson(Map<String, dynamic> json) =>
      _$IntegrationTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationTestDataToJson(this);
}

@JsonSerializable()
class SwitchAccountsTestData {
  const SwitchAccountsTestData({
    this.recoveryPhraseTwo,
    this.nameTwo,
  });

  final String? recoveryPhraseTwo;
  final String? nameTwo;

  // ignore: member-ordering
  factory SwitchAccountsTestData.fromJson(Map<String, dynamic> json) =>
      _$SwitchAccountsTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$SwitchAccountsTestDataToJson(this);
}

@JsonSerializable()
class SendHashTestData {
  const SendHashTestData({
    this.accountAddress,
  });

  final String? accountAddress;

  // ignore: member-ordering
  factory SendHashTestData.fromJson(Map<String, dynamic> json) =>
      _$SendHashTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$SendHashTestDataToJson(this);
}
