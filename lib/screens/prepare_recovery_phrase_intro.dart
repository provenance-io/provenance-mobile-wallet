import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/screens/recovery_words.dart';

class PrepareRecoveryPhraseIntro extends StatelessWidget {
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  final String accountName;

  PrepareRecoveryPhraseIntro(this.flowType, this.accountName, {this.currentStep, this.numberOfSteps});

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
                        'Prepare to write down your recovery passphrase',
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
                        'The only way to recover your account is with this recovery passphrase.',
                        style: FwTextStyle.m,
                        textAlign: TextAlign.center,
                        color: FwColor.globalNeutral550,
                      ),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: FwText(
                        'Warning: Do not share this passphrase with anyone, as it grants full access to your account.',
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
                              'I’m ready to begin',
                              style: FwTextStyle.mBold,
                              color: FwColor.white,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(RecoveryWords(flowType, accountName, currentStep: currentStep, numberOfSteps: numberOfSteps).route());
                            })),
                    SizedBox(
                      height: 40,
                    ),
                    if (numberOfSteps != null) ProgressStepper(currentStep ?? 0, numberOfSteps ?? 1, padding: EdgeInsets.only(left: 20, right: 20)),
                    if (numberOfSteps != null) VerticalSpacer.xxLarge()
                  ],
                ))));
  }
}
