import 'dart:convert';
import 'dart:io';

import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/util/integration_test_data.dart';

void main() async {
  final file = File('../integration_test_data.json');
  IntegrationTestData? existingData;
  if (await file.exists()) {
    final json = await file.readAsString();
    existingData = IntegrationTestData.fromJson(jsonDecode(json));
  } else {
    await file.create();
  }

  final buffer = StringBuffer();

  final sampleData = IntegrationTestData(
    accountName: '<name>',
    cipherPin: '<cipher pin>',
    recoveryPhrase: '<recovery phrase>',
    switchAccountsTest: SwitchAccountsTestData(
      recoveryPhraseTwo: '<recovery phrase 2>',
      nameTwo: '<name two>',
    ),
    sendHashTest: SendHashTestData(
      accountAddress: '<account address>',
    ),
  );

  final data = IntegrationTestData(
    accountName: existingData?.accountName ?? sampleData.accountName,
    cipherPin: existingData?.cipherPin ?? sampleData.cipherPin,
    recoveryPhrase: existingData?.recoveryPhrase ?? sampleData.recoveryPhrase,
    switchAccountsTest:
        existingData?.switchAccountsTest ?? sampleData.switchAccountsTest,
    sendHashTest: existingData?.sendHashTest ?? sampleData.sendHashTest,
  );

  buffer.writeln(prettyJson(data));

  await file.writeAsString(buffer.toString());
}
