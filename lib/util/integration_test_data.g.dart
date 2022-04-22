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
    );

Map<String, dynamic> _$IntegrationTestDataToJson(
        IntegrationTestData instance) =>
    <String, dynamic>{
      'recoverWalletTest': instance.recoverWalletTest,
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
