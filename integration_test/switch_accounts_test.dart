import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/util/integration_test_data.dart';

import 'util/key_extension.dart';
import 'util/widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Switch accounts from \'one\' to \'two\'',
    (tester) async {
      final data = await tester.loadTestData();

      app.main(
        [
          prettyJson(
            IntegrationTestData(
              accountName: data.accountName,
              cipherPin: data.cipherPin,
              recoveryPhrase: data.recoveryPhrase,
              switchAccountsTest: data.switchAccountsTest,
            ),
          )
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

      Dashboard.keyAccountNameText.expectPwText(data.accountName!, tester);
      await Dashboard.keyOpenAccountsButton.tap(tester);
      await AccountContainer.keyAccountEllipsisName(
              data.switchAccountsTest!.nameTwo!)
          .tap(tester);
      await AccountsScreen.keySelectAccountButton.tap(tester);

      await PwAppBar.keyLeadingIconButton.tap(tester);

      Dashboard.keyAccountNameText
          .expectPwText(data.switchAccountsTest!.nameTwo!, tester);
    },
  );
}
