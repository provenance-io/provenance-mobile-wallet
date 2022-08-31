import 'package:json_annotation/json_annotation.dart';

part 'integration_test_data.g.dart';

@JsonSerializable()
class IntegrationTestData {
  const IntegrationTestData({
    this.recoverWalletTest,
    this.switchAccountsTest,
  });

  final RecoverWalletTestData? recoverWalletTest;
  final SwitchAccountsTestData? switchAccountsTest;

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

@JsonSerializable()
class SwitchAccountsTestData {
  const SwitchAccountsTestData({
    this.recoveryPhraseOne,
    this.recoveryPhraseTwo,
    this.nameOne,
    this.nameTwo,
    this.cipherPin,
  });

  final String? recoveryPhraseOne;
  final String? recoveryPhraseTwo;
  final String? nameOne;
  final String? nameTwo;
  final String? cipherPin;

  // ignore: member-ordering
  factory SwitchAccountsTestData.fromJson(Map<String, dynamic> json) =>
      _$SwitchAccountsTestDataFromJson(json);

  Map<String, dynamic> toJson() => _$SwitchAccountsTestDataToJson(this);
}
