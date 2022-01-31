import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/image_placeholder.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry.dart';
import 'package:provenance_wallet/screens/recovery_words.dart';
import 'package:provenance_wallet/util/strings.dart';

class PresentInformation extends StatelessWidget {
  PresentInformation(
    this.info,
  );

  final InfoModel info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        title: FwText(
          info.title,
          style: FwTextStyle.h5,
          textAlign: TextAlign.left,
          color: FwColor.globalNeutral550,
        ),
        leading: IconButton(
          icon: FwIcon(
            FwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressStepper(
              info.currentStep ?? 0,
              info.numberOfSteps ?? 1,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImagePlaceholder(),
              ],
            ),
            SizedBox(
              height: 48,
            ),
            !info.isExistingAccount
                ? Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: FwText(
                      Strings.prepareToWriteDownYourRecoveryPassphrase,
                      style: FwTextStyle.extraLarge,
                      textAlign: TextAlign.center,
                      color: FwColor.globalNeutral550,
                    ),
                  )
                : Container(),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: FwText(
                info.bodyText,
                style: FwTextStyle.m,
                textAlign: TextAlign.center,
                color: FwColor.globalNeutral550,
              ),
            ),
            Expanded(child: Container()),
            info.isExistingAccount
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: FwText(
                      Strings.warningDoNotShare,
                      style: FwTextStyle.sBold,
                      textAlign: TextAlign.center,
                      color: FwColor.globalNeutral450,
                    ),
                  ),
            SizedBox(
              height: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: FwButton(
                child: FwText(
                  info.buttonText,
                  style: FwTextStyle.mBold,
                  color: FwColor.white,
                ),
                onPressed: () {
                  var widget = info.getNextStep();
                  if (widget != null) {
                    Navigator.of(context).push(widget.route());
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

class InfoModel {
  InfoModel(
    this.flowType,
    this.accountName,
    this.title,
    this.bodyText,
    this.buttonText, {
    this.currentStep,
    this.numberOfSteps,
  });
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  final String accountName;
  final String title;
  final String bodyText;
  final String buttonText;

  bool get isExistingAccount {
    return flowType == WalletAddImportType.onBoardingRecover ||
        flowType == WalletAddImportType.dashboardRecover;
  }

  Widget? getNextStep() {
    if (flowType == WalletAddImportType.onBoardingRecover ||
        flowType == WalletAddImportType.dashboardRecover) {
      return RecoverPassphraseEntry(
        flowType,
        accountName,
        currentStep: currentStep,
        numberOfSteps: numberOfSteps,
      );
    } else if (flowType == WalletAddImportType.onBoardingAdd ||
        flowType == WalletAddImportType.dashboardAdd) {
      return RecoveryWords(
        flowType,
        accountName,
        currentStep: currentStep,
        numberOfSteps: numberOfSteps,
      );
    } else {
      return null;
    }
  }
}
