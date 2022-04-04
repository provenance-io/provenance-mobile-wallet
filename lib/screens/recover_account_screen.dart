import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
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

  final WalletAddImportType flowType;
  final String accountName;
  final int currentStep;
  final int? numberOfSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.recoverAccount,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressStepper(
              currentStep,
              numberOfSteps ?? 1,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
              ),
            ),
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
            Image.asset(
              AssetPaths.images.recoverAccount,
              width: 180,
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
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                onPressed: () {
                  if (flowType == WalletAddImportType.onBoardingRecover ||
                      flowType == WalletAddImportType.dashboardRecover) {
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
      ),
    );
  }
}
