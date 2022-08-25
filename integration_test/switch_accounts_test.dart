import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/screens/home/accounts/basic_account_item.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';

import 'util/key_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Switch accounts from \'one\' to \'two\'',
    (tester) async {
      app.main();

      await tester.pumpAndSettle(Duration(seconds: 1));

      final keyZero = keyPinPadNumber(0);

      await keyZero.tap(tester, times: 6);
      await tester.pumpAndSettle(Duration(seconds: 1));

      Dashboard.keyAccountNameText.expectPwText("One", tester);
      await Dashboard.keyOpenAccountsButton.tap(tester);
      await AccountContainer.keyAccountEllipsisName("Two").tap(tester);
      await BasicAccountItem.keySelectAccountButton.tap(tester);

      await tester.pumpAndSettle(Duration(seconds: 1));
      await PwAppBar.keyLeadingIconButton.tap(tester);

      Dashboard.keyAccountNameText.expectPwText("Two", tester);
    },
  );
}
