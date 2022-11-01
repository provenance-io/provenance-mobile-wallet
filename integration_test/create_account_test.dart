import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/main.dart' as app;
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/account_setup_confirmation_screen.dart';
import 'package:provenance_wallet/screens/backup_complete_screen.dart';
import 'package:provenance_wallet/screens/create_passphrase_screen.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/screens/pin/pin_pad.dart';
import 'package:provenance_wallet/screens/recovery_words/recovery_words_screen.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_confirm_screen.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_button.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_selector.dart';

import 'util/key_extension.dart';
import 'util/widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Starting from nothing, should create basic account.',
    (tester) async {
      app.main([]);

      await tester.pumpAndSettle();

      final testData = await tester.loadTestData();

      await LandingScreen.keyAddAccountButton.tap(tester);
      await AccountNameScreen.keyNameTextField.tap(tester);

      final accountName = testData.accountName!;
      await AccountNameScreen.keyNameTextField.enterText(accountName, tester);

      await AccountNameScreen.keyContinueButton.tap(tester);

      await CreatePassphraseScreen.keyContinueButton.scrollUntilVisible(
        tester,
        scrollable: PwOnboardingScreen.keyScrollView,
      );

      await CreatePassphraseScreen.keyContinueButton.tap(tester);

      List<String> words = [];
      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == "Clipboard.setData") {
          words = methodCall.arguments
              .toString()
              .replaceAll('{text: ', '')
              .replaceAll('}', '')
              .split(' ');
        }
      });

      await RecoveryWordsScreen.keyCopyButton.scrollUntilVisible(
        tester,
        scrollable: PwOnboardingScreen.keyScrollView,
      );
      await RecoveryWordsScreen.keyCopyButton.tap(tester);
      await RecoveryWordsScreen.keySnackbar.drag(tester, dx: 0, dy: 500);
      await RecoveryWordsScreen.keyContinueButton.scrollUntilVisible(
        tester,
        scrollable: PwOnboardingScreen.keyScrollView,
      );
      await RecoveryWordsScreen.keyContinueButton.tap(tester);

      final word1 = int.parse(WordSelector.keyWordSelector(0)
          .pwText(tester)
          .replaceAll("Word #", ""));
      final word2 = int.parse(WordSelector.keyWordSelector(1)
          .pwText(tester)
          .replaceAll("Word #", ""));
      final word3 = int.parse(WordSelector.keyWordSelector(2)
          .pwText(tester)
          .replaceAll("Word #", ""));
      final word4 = int.parse(WordSelector.keyWordSelector(3)
          .pwText(tester)
          .replaceAll("Word #", ""));

      await WordButton.keyWordButton(words[word1 - 1], 0).tap(tester);
      await WordButton.keyWordButton(words[word2 - 1], 1).tap(tester);
      await WordButton.keyWordButton(words[word3 - 1], 2).tap(tester);
      await WordButton.keyWordButton(words[word4 - 1], 3).tap(tester);

      await RecoveryWordsConfirmScreen.keyCheckbox.tap(tester);
      await RecoveryWordsConfirmScreen.keyContinueButton.tap(tester);
      await BackupCompleteScreen.keyContinueButton.scrollUntilVisible(
        tester,
        scrollable: PwOnboardingScreen.keyScrollView,
      );
      await BackupCompleteScreen.keyContinueButton.tap(tester);

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
