import 'package:provenance_wallet/common/enum/account_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_entry_screen.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                VerticalSpacer.large(),
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
                VerticalSpacer.xxLarge(),
                Image.asset(
                  Assets.imagePaths.recoverAccount,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: PwButton(
                    autofocus: true,
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
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
