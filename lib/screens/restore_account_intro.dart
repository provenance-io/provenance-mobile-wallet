import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/screens/recover_passphrase_entry.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

class RestoreAccountIntro extends StatelessWidget {
  final WalletAddImportType flowType;
  final int? currentStep;
  final int? numberOfSteps;
  final String accountName;

  RestoreAccountIntro(this.flowType, this.accountName,
      {this.currentStep, this.numberOfSteps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
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
            child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 158,
                          width: 158,
                          decoration: BoxDecoration(
                              color: Color(0xFF9196AA),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(79))),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 48,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: FwText(
                        Strings.recoverAccount,
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
                        Strings.inTheFollowingStepsText,
                        style: FwTextStyle.m,
                        textAlign: TextAlign.center,
                        color: FwColor.globalNeutral550,
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: FwButton(
                            child: FwText(
                              Strings.next,
                              style: FwTextStyle.mBold,
                              color: FwColor.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(RecoverPassphraseEntry(
                                flowType,
                                accountName,
                                currentStep: currentStep,
                                numberOfSteps: numberOfSteps,
                              ).route());
                            })),
                    SizedBox(
                      height: 40,
                    ),
                    if (numberOfSteps != null)
                      ProgressStepper((currentStep ?? 0), numberOfSteps ?? 1,
                          padding: EdgeInsets.only(left: 20, right: 20)),
                    if (numberOfSteps != null) VerticalSpacer.xxLarge()
                  ],
                ))));
  }
}
