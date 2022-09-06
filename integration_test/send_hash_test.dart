import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/basic_account_item.dart';
import 'package:provenance_wallet/screens/home/dashboard/account_portfolio.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_success/send_success_screen.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/util/integration_test_data.dart';

import 'util/key_extension.dart';
import 'util/widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Sending hash from one account to another',
    (tester) async {
      final data = await tester.loadTestData();
      app.main(
        [
          prettyJson(
            IntegrationTestData(
              accountName: data.accountName,
              cipherPin: data.cipherPin,
              recoveryPhrase: data.recoveryPhrase,
              sendHashTest: data.sendHashTest,
            ),
          ),
        ],
      );

      await app.mainCompleter.future;
      await tester.pumpAndSettle();

      final pin = data.cipherPin!;

      for (var i = 0; i < pin.length; i++) {
        final number = int.parse(pin[i]);
        final key = keyPinPadNumber(number);
        await key.tap(tester);
      }

      double beginningHash =
          double.parse(Dashboard.keyAssetAmount("HASH").pwText(tester));

      if (beginningHash < 10) {
        String clipboardData = "";
        SystemChannels.platform
            .setMockMethodCallHandler((MethodCall methodCall) async {
          if (methodCall.method == "Clipboard.setData") {
            clipboardData = methodCall.arguments
                .toString()
                .replaceAll('{text: ', '')
                .replaceAll('}', '');
          }
        });
        await Dashboard.keyOpenAccountsButton.tap(tester);
        await AccountContainer.keyAccountEllipsisName(data.accountName!)
            .tap(tester);
        await BasicAccountItem.keyCopyAccountNumberButton.tap(tester);
        Map<String, dynamic> json = {'address': clipboardData};
        final res = await TestHttpClient(baseUrl: 'https://test.provenance.io/')
            .post('blockchain/faucet/external', body: json);

        expect(true, res.isSuccessful);
        await PwAppBar.keyLeadingIconButton.tap(tester);
        await Dashboard.keyListColumn.drag(tester, dx: 0, dy: 500);
        beginningHash =
            double.parse(Dashboard.keyAssetAmount("HASH").pwText(tester));
      }

      await AccountPortfolio.keySendButton.tap(tester);
      await SendPage.keyAddressField
          .enterText(data.sendHashTest!.accountAddress!, tester);
      await SendAssetList.keySelectAssetButton.tap(tester);
      await SendAssetList.keyDropDownItem("HASH").tap(tester);
      await SendPage.keyNextButton.tap(tester);
      await SendAmountPage.keyEnterAmountField.enterText("5", tester);
      await SendAmountPage.keyNextButton.scrollUntilVisible(
        tester,
        scrollable: ValueKey("FeeRow"),
      );
      await SendAmountPage.keyNextButton.tap(tester);
      await SendReviewPage.keySendButton.tap(tester);
      await pumpEventQueue();

      // Text is something like "6.473829789 HASH"
      final textPrice =
          SendSuccessScreen.keyTransactionAmount.pwText(tester).split(" ")[0];
      final transactionAmount = double.parse(textPrice);

      await SendSuccessScreen.keyDoneButton.tap(tester);
      //await Dashboard.keyListColumn.drag(tester, dx: 0, dy: 500);

      // The expected value uses less hash than the actual value, so we only look at 2 decimal places.
      final compareValue =
          (beginningHash - transactionAmount).toStringAsFixed(2);

      final finalValue =
          double.parse(Dashboard.keyAssetAmount("HASH").pwText(tester))
              .toStringAsFixed(2);
      expectLater(finalValue, compareValue);
    },
  );
}
