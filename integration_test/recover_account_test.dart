import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/account_setup_confirmation_screen.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_entry_screen.dart';

import 'util/key_extension.dart';
import 'util/widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Given account name and passphrase then recover account flow opens dashboard',
    (tester) async {
      app.main([]);

      final testData = await tester.loadTestData();

      await tester.pumpAndSettle(Duration(seconds: 1));

      await LandingScreen.keyImportAccountButton.tap(tester);
      await AccountNameScreen.keyNameTextField.tap(tester);

      final accountName = testData.accountName!;
      await AccountNameScreen.keyNameTextField.enterText(accountName, tester);

      await AccountNameScreen.keyContinueButton.tap(tester);
      await RecoverAccountScreen.keyContinueButton.tap(tester);

      while (tester
          .widgetList(
            find.byKey(RecoverPassphraseEntryScreen.networkName),
          )
          .isEmpty) {
        await RecoverPassphraseEntryScreen.keyAppBar.tap(tester);
      }

      RecoverPassphraseEntryScreen.networkName.expect(tester);

      final testNet = Coin.testNet.displayName;
      final mainNet = Coin.mainNet.displayName;

      final actualNetwork =
          RecoverPassphraseEntryScreen.networkName.pwText(tester);

      if (actualNetwork.endsWith(mainNet)) {
        await RecoverPassphraseEntryScreen.networkToggle.tap(tester);
      }

      RecoverPassphraseEntryScreen.networkName
          .expectPwTextEndsWith(testNet, tester);

      const wordOneIndex = 0;
      final keyWordOne =
          RecoverPassphraseEntryScreen.keyPassphraseWordTextField(wordOneIndex);

      final phrase = testData.recoveryPhrase ?? "";

      await keyWordOne.tap(tester);
      await keyWordOne.enterText(phrase, tester);

      await tester.unfocusAndSettle();

      await RecoverPassphraseEntryScreen.keyContinueButton.scrollUntilVisible(
        tester,
        scrollable: RecoverPassphraseEntryScreen.wordList,
      );

      await RecoverPassphraseEntryScreen.keyContinueButton.tap(tester);

      final pin = testData.cipherPin ?? "";

      for (var i = 0; i < pin.length; i++) {
        final number = int.parse(pin[i]);
        final key = keyPinPadNumber(number);
        await key.tap(tester);
      }
      for (var i = 0; i < pin.length; i++) {
        final number = int.parse(pin[i]);
        final key = keyPinPadNumber(number);
        await key.tap(tester);
      }

      await EnableFaceIdScreen.keySkipButton.tap(tester);
      await AccountSetupConfirmationScreen.keyContinueButton.tap(tester);
      Dashboard.keyAccountNameText.expectPwText(accountName, tester);
    },
  );
}
