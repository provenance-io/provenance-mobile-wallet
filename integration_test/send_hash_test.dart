import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/home/dashboard/account_portfolio.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_asset_list.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_success/send_success_screen.dart';
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

      final beginningHash =
          double.parse(Dashboard.keyAssetAmount("HASH").pwText(tester));
      print(beginningHash);

      if (beginningHash < 10) {
        // TODO: get current address and hit the faucet.
      }

      await AccountPortfolio.keySendButton.tap(tester);
      await SendPage.keyAddressField
          .enterText(data.sendHashTest!.accountAddress!, tester);

      await SendAssetList.keySelectAssetButton.tap(tester);

      // final widgets = tester.allWidgets
      //     .map((e) => e.toStringDeep())
      //     .toList()
      //     .join("------\n");
      // print(widgets);
      // // SendAssetCell

      await SendAssetList.keyDropDownItem("HASH").tap(tester);
      await SendPage.keyNextButton.tap(tester);

      await SendAmountPage.keyEnterAmountField.enterText("5", tester);

      await SendAmountPage.keyNextButton.scrollUntilVisible(
        tester,
        scrollable: ValueKey("FeeRow"),
      );
      await SendAmountPage.keyNextButton.tap(tester);

      // await SendReviewPage.keySendButton.scrollUntilVisible(
      //   tester,
      //   scrollable: SendReviewPage.keyReviewColumn,
      // );

      await SendReviewPage.keySendButton.tap(tester);

      await pumpEventQueue();

      final transactionAmount =
          double.parse(SendSuccessScreen.keyTransactionAmount.pwText(tester));
      print(transactionAmount);

      SendSuccessScreen.keyDoneButton.tap(tester);
      //await tester.pumpAndSettle(Duration(seconds: 1));

      Dashboard.keyAssetAmount("HASH")
          .expectPwText((beginningHash - transactionAmount).toString(), tester);
    },
  );
}
