import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/account_name.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen.dart';
import 'package:provenance_wallet/screens/wallet_setup_confirmation.dart';

import 'util/widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Given wallet name and passphrase then recover wallet flow opens dashboard',
    (tester) async {
      app.main();

      final testData = await tester.loadTestData();

      await tester.pumpAndSettle();

      await tester.tapKeyAndSettle(
        LandingScreen.keyRecoverWalletButton,
      );

      await tester.tapKeyAndSettle(
        AccountName.keyNameTextField,
      );

      const accountName = 'one';
      await tester.enterTextAndSettle(
        AccountName.keyNameTextField,
        accountName,
      );

      await tester.tapKeyAndSettle(
        AccountName.keyContinueButton,
      );

      await tester.tapKeyAndSettle(
        RecoverAccountScreen.keyContinueButton,
      );

      await tester.tapKeyAndSettle(
        RecoverPassphraseEntryScreen.keyAppBar,
        times: RecoverPassphraseEntryScreenState.toggleAdvancedUICount + 2,
      );

      tester.expectKey(
        RecoverPassphraseEntryScreen.networkName,
      );

      var networkName = tester.widgetWithKey<PwText>(
        RecoverPassphraseEntryScreen.networkName,
      );
      expect(networkName.data.contains(Coin.mainNet.displayName), isTrue);

      await tester.tapKeyAndSettle(
        RecoverPassphraseEntryScreen.networkName,
      );

      networkName = tester.widgetWithKey<PwText>(
        RecoverPassphraseEntryScreen.networkName,
      );
      expect(networkName.data.contains(Coin.testNet.displayName), isTrue);

      const wordOneIndex = 0;
      final keyWordOne =
          RecoverPassphraseEntryScreen.keyPassphraseWordTextField(wordOneIndex);

      final phrase = testData.recoverWalletTest!.recoveryPhrase!;

      await tester.tapKeyAndSettle(keyWordOne);
      await tester.enterTextAndSettle(keyWordOne, phrase);

      await tester.unfocusAndSettle();

      await tester.scrollUntilVisibleAndSettle(
        key: RecoverPassphraseEntryScreen.keyContinueButton,
        scrollable: RecoverPassphraseEntryScreen.wordList,
      );

      await tester.tapKeyAndSettle(
        RecoverPassphraseEntryScreen.keyContinueButton,
      );

      final keyZero = keyPinPadNumber(0);

      // Initial pin
      await tester.tapKeyAndSettle(keyZero, times: 6);

      // Verify pin
      await tester.tapKeyAndSettle(keyZero, times: 6);

      await tester.tapKeyAndSettle(
        EnableFaceIdScreen.keyEnableButton,
      );

      await tester.tapKeyAndSettle(
        WalletSetupConfirmation.keyContinueButton,
      );

      final nameWidget = tester.widgetWithKey<PwText>(
        Dashboard.keyWalletNameText,
      );

      expect(nameWidget.data, accountName);
    },
  );
}
