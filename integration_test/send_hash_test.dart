import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/home/accounts/account_cell.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/faucet_screen.dart';
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

      await tester.pumpAndSettle();

      final pin = data.cipherPin!;

      for (var i = 0; i < pin.length; i++) {
        final number = int.parse(pin[i]);
        final key = keyPinPadNumber(number);
        await key.tap(tester);
      }

      Decimal beginningHash =
          Decimal.parse(Dashboard.keyAssetAmount("HASH").pwText(tester));

      if (beginningHash < Decimal.parse("10")) {
        await Dashboard.keyOpenAccountsButton.tap(tester);
        await AccountContainer.keyAccountEllipsisName(data.accountName!)
            .tap(tester);
        await AccountCell.keyAddHashButton.tap(tester);
        await FaucetScreen.keyAddHashButton.tap(tester);

        await PwAppBar.keyLeadingIconButton.tap(tester);
        await PwAppBar.keyLeadingIconButton.tap(tester);
        await Dashboard.keyListColumn.drag(tester, dx: 0, dy: 500);
        beginningHash =
            Decimal.parse(Dashboard.keyAssetAmount("HASH").pwText(tester));
      }

      await AccountPortfolio.keySendButton.tap(tester);
      await SendPage.keyAddressField
          .enterText(data.sendHashTest!.accountAddress!, tester);
      while (tester
          .widgetList(
            find.byKey(SendAssetList.keySelectAssetButton),
          )
          .isEmpty) {
        await tester.pumpAndSettle();
      }
      await SendAssetList.keySelectAssetButton.tap(tester);
      await SendAssetList.keyDropDownItem("HASH").tap(tester);
      await SendPage.keyNextButton.tap(tester);
      await SendAmountPage.keyEnterAmountField.enterText("5", tester);
      await SendAmountPage.keyNextButton.scrollUntilVisible(
        tester,
        scrollable: ValueKey("FeeRow"),
      );

      while (tester
          .widgetList(
            find.byKey(SendAmountPage.keyNextButton),
          )
          .isNotEmpty) {
        await SendAmountPage.keyNextButton.tap(tester);
      }

      await SendReviewPage.keySendButton.tapWhenExists(tester);

      while (tester
          .widgetList(
            find.byKey(SendSuccessScreen.keyTransactionAmount),
          )
          .isEmpty) {
        await tester.pumpAndSettle();
      }

      // Text is something like "6.473829789 HASH"
      final textPrice =
          SendSuccessScreen.keyTransactionAmount.pwText(tester).split(" ")[0];
      final transactionAmount = Decimal.parse(textPrice);

      await SendSuccessScreen.keyDoneButton.tap(tester);
      await tester.pumpAndSettle();
      await Dashboard.keyListColumn.drag(tester, dx: 0, dy: 500);

      // The expected value uses less hash than the actual value, so we only look at 1 decimal place.
      final compareValue =
          (beginningHash - transactionAmount).toStringAsFixed(1);

      final finalValue =
          double.parse(Dashboard.keyAssetAmount("HASH").pwText(tester))
              .toStringAsFixed(1);
      expectLater(finalValue, compareValue);
    },
  );
}
