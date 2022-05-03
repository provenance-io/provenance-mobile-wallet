import 'package:provenance_wallet/common/enum/account_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoverAccountScreen extends StatelessWidget {
  const RecoverAccountScreen(
    this.flowType,
    this.accountName, {
    Key? key,
    required this.currentStep,
    this.numberOfSteps,
  }) : super(key: key);

  static final keyContinueButton =
      ValueKey('$RecoverAccountScreen.continue_button');

  final AccountAddImportType flowType;
  final String accountName;
  final int currentStep;
  final int? numberOfSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: Strings.recoverAccount,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          currentStep,
          numberOfSteps ?? 1,
        ),
      ),
      body: PwOnboardingScreen(
        children: [
          VerticalSpacer.largeX6(),
          VerticalSpacer.xxLarge(),
          PwText(
            Strings.recoverAccount.toUpperCase(),
            style: PwTextStyle.headline2,
            textAlign: TextAlign.center,
          ),
          VerticalSpacer.large(),
          Padding(
            padding: EdgeInsets.only(
              right: Spacing.xxLarge,
              left: Spacing.xxLarge,
            ),
            child: PwText(
              Strings.inTheFollowingStepsText,
              style: PwTextStyle.body,
              textAlign: TextAlign.center,
            ),
          ),
          VerticalSpacer.large(),
          VerticalSpacer.medium(),
          Container(
            width: 180,
            alignment: Alignment.center,
            child: Image.asset(
              Assets.imagePaths.recoverAccount,
              width: 180,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          VerticalSpacer.xxLarge(),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: PwButton(
              child: PwText(
                Strings.continueName,
                key: RecoverAccountScreen.keyContinueButton,
                style: PwTextStyle.bodyBold,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () {
                if (flowType == AccountAddImportType.onBoardingRecover ||
                    flowType == AccountAddImportType.dashboardRecover) {
                  Navigator.of(context).push(RecoverPassphraseEntryScreen(
                    flowType,
                    accountName,
                    currentStep: currentStep + 1,
                    numberOfSteps: numberOfSteps,
                  ).route());
                }
              },
            ),
          ),
          VerticalSpacer.xxLarge(),
          VerticalSpacer.xxLarge(),
        ],
      ),
    );
  }
}
