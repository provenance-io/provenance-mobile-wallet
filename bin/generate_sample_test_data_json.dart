import 'dart:convert';
import 'dart:io';

import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_blockchain_wallet/util/integration_test_data.dart';

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
    recoverWalletTest: RecoverWalletTestData(
      recoveryPhrase: '<recovery phrase>',
    ),
  );

  final data = IntegrationTestData(
    recoverWalletTest:
        existingData?.recoverWalletTest ?? sampleData.recoverWalletTest,
  );

  buffer.writeln(prettyJson(data));

  await file.writeAsString(buffer.toString());
}
