import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        title: PwText(
          Strings.createPassphrase,
          style: PwTextStyle.subhead,
          textAlign: TextAlign.left,
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 15),
          child: IconButton(
            icon: PwIcon(
              PwIcons.back,
              size: 14,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: viewportConstraints,
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
                        color: PwColor.neutral50,
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
                        color: PwColor.neutral50,
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
                      padding: EdgeInsets.only(
                        left: Spacing.xxLarge,
                        right: Spacing.xxLarge,
                      ),
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
                          style: PwTextStyle.bodyBold,
                          color: PwColor.neutralNeutral,
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
                    VerticalSpacer.largeX4(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
