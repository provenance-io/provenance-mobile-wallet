import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/recovery_words.dart';
import 'package:provenance_wallet/util/strings.dart';

class PrepareRecoveryPhraseIntro extends StatelessWidget {
  PrepareRecoveryPhraseIntro(
    this.flowType,
    this.accountName, {
    this.currentStep,
    this.numberOfSteps,
  });

  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  final String accountName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: FwText(
          Strings.createPassphrase,
          style: FwTextStyle.h5,
          textAlign: TextAlign.left,
          color: FwColor.globalNeutral550,
        ),
        leading: IconButton(
          icon: FwIcon(
            FwIcons.back,
            size: 24,
            color: Color(0xFF3D4151),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 158,
                  width: 158,
                  decoration: BoxDecoration(
                    color: Color(0xFF9196AA),
                    borderRadius: BorderRadius.all(Radius.circular(79)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: FwText(
                Strings.prepareToWriteDownYourRecoveryPassphrase,
                style: FwTextStyle.extraLarge,
                textAlign: TextAlign.center,
                color: FwColor.globalNeutral550,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: FwText(
                Strings.theOnlyWayToRecoverYourAccount,
                style: FwTextStyle.m,
                textAlign: TextAlign.center,
                color: FwColor.globalNeutral550,
              ),
            ),
            Expanded(child: Container()),
            Padding(
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
                  Strings.iAmReady,
                  style: FwTextStyle.mBold,
                  color: FwColor.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(RecoveryWords(
                    flowType,
                    accountName,
                    currentStep: currentStep,
                    numberOfSteps: numberOfSteps,
                  ).route());
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
