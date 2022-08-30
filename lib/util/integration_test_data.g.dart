// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_test_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntegrationTestData _$IntegrationTestDataFromJson(Map<String, dynamic> json) =>
    IntegrationTestData(
      recoveryPhrase: json['recoveryPhrase'] as String?,
      accountName: json['accountName'] as String?,
      cipherPin: json['cipherPin'] as String?,
      switchAccountsTest: json['switchAccountsTest'] == null
          ? null
          : SwitchAccountsTestData.fromJson(
              json['switchAccountsTest'] as Map<String, dynamic>),
      sendHashTest: json['sendHashTest'] == null
          ? null
          : SendHashTestData.fromJson(
              json['sendHashTest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IntegrationTestDataToJson(
        IntegrationTestData instance) =>
    <String, dynamic>{
      'recoveryPhrase': instance.recoveryPhrase,
      'accountName': instance.accountName,
      'cipherPin': instance.cipherPin,
      'switchAccountsTest': instance.switchAccountsTest,
      'sendHashTest': instance.sendHashTest,
    };

SwitchAccountsTestData _$SwitchAccountsTestDataFromJson(
        Map<String, dynamic> json) =>
    SwitchAccountsTestData(
      recoveryPhraseTwo: json['recoveryPhraseTwo'] as String?,
      nameTwo: json['nameTwo'] as String?,
    );

Map<String, dynamic> _$SwitchAccountsTestDataToJson(
        SwitchAccountsTestData instance) =>
    <String, dynamic>{
      'recoveryPhraseTwo': instance.recoveryPhraseTwo,
      'nameTwo': instance.nameTwo,
    };

SendHashTestData _$SendHashTestDataFromJson(Map<String, dynamic> json) =>
    SendHashTestData(
      accountAddress: json['accountAddress'] as String?,
    );

Map<String, dynamic> _$SendHashTestDataToJson(SendHashTestData instance) =>
    <String, dynamic>{
      'accountAddress': instance.accountAddress,
    };
