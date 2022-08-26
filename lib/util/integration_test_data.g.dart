// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_test_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegrationTestData _$IntegrationTestDataFromJson(Map<String, dynamic> json) =>
    IntegrationTestData(
      recoverWalletTest: json['recoverWalletTest'] == null
          ? null
          : RecoverWalletTestData.fromJson(
              json['recoverWalletTest'] as Map<String, dynamic>),
      switchAccountsTest: json['switchAccountsTest'] == null
          ? null
          : SwitchAccountsTestData.fromJson(
              json['switchAccountsTest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IntegrationTestDataToJson(
        IntegrationTestData instance) =>
    <String, dynamic>{
      'recoverWalletTest': instance.recoverWalletTest,
      'switchAccountsTest': instance.switchAccountsTest,
    };

RecoverWalletTestData _$RecoverWalletTestDataFromJson(
        Map<String, dynamic> json) =>
    RecoverWalletTestData(
      recoveryPhrase: json['recoveryPhrase'] as String?,
    );

Map<String, dynamic> _$RecoverWalletTestDataToJson(
        RecoverWalletTestData instance) =>
    <String, dynamic>{
      'recoveryPhrase': instance.recoveryPhrase,
    };

SwitchAccountsTestData _$SwitchAccountsTestDataFromJson(
        Map<String, dynamic> json) =>
    SwitchAccountsTestData(
      recoveryPhraseOne: json['recoveryPhraseOne'] as String?,
      recoveryPhraseTwo: json['recoveryPhraseTwo'] as String?,
      nameOne: json['nameOne'] as String?,
      nameTwo: json['nameTwo'] as String?,
      cipherPin: json['cipherPin'] as String?,
    );

Map<String, dynamic> _$SwitchAccountsTestDataToJson(
        SwitchAccountsTestData instance) =>
    <String, dynamic>{
      'recoveryPhraseOne': instance.recoveryPhraseOne,
      'recoveryPhraseTwo': instance.recoveryPhraseTwo,
      'nameOne': instance.nameOne,
      'nameTwo': instance.nameTwo,
      'cipherPin': instance.cipherPin,
    };
