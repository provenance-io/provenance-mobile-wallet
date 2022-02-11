import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/recovery_words.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class CreatePassphraseScreen extends StatelessWidget {
  const CreatePassphraseScreen(
    this.flowType,
    this.accountName, {
    this.currentStep,
    this.numberOfSteps,
  });

  final WalletAddImportType flowType;
  final String accountName;
  final int? currentStep;
  final int? numberOfSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.createPassphrase,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral750,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressStepper(
              currentStep ?? 0,
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
              Strings.savePassphrase,
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
                Strings.prepareToWriteDownYourRecoveryPhrase,
                style: PwTextStyle.body,
                textAlign: TextAlign.center,
              ),
            ),
            VerticalSpacer.large(),
            Padding(
              padding: EdgeInsets.only(
                right: Spacing.xxLarge,
                left: Spacing.xxLarge,
              ),
              child: PwText(
                Strings.theOnlyWayToRecoverYourAccount,
                style: PwTextStyle.body,
                textAlign: TextAlign.center,
              ),
            ),
            VerticalSpacer.large(),
            VerticalSpacer.medium(),
            Image.asset(
              AssetPaths.images.createPassphrase,
              width: 180,
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwText(
                Strings.warningDoNotShare,
                style: PwTextStyle.body,
                textAlign: TextAlign.center,
                color: PwColor.error,
              ),
            ),
            VerticalSpacer.xxLarge(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwButton(
                child: PwText(
                  Strings.continueName,
                  style: PwTextStyle.mBold,
                  color: PwColor.white,
                ),
                onPressed: () {
                  if (flowType == WalletAddImportType.onBoardingAdd ||
                      flowType == WalletAddImportType.dashboardAdd) {
                    Navigator.of(context).push(RecoveryWords(
                      flowType,
                      accountName,
                      currentStep: currentStep,
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
