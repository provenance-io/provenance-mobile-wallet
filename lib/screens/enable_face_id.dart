import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/common/widgets/modal_loading.dart';
import 'package:flutter_tech_wallet/main.dart';
import 'package:flutter_tech_wallet/screens/dashboard/dashboard.dart';
import 'package:flutter_tech_wallet/util/local_auth_helper.dart';
import 'package:flutter_tech_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class EnableFaceId extends StatelessWidget {
  EnableFaceId({
    this.words,
    this.accountName,
    this.code,
    this.currentStep,
    this.numberOfSteps,
    this.flowType = WalletAddImportType.onBoardingAdd,
  });

  final List<String>? words;
  final String? accountName;
  final List<int>? code;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

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
                  Strings.useFaceId,
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
                  Strings.useYourFaceId,
                  style: FwTextStyle.m,
                  textAlign: TextAlign.center,
                  color: FwColor.globalNeutral550,
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwButton(
                  child: FwText(
                    Strings.enableFaceId,
                    style: FwTextStyle.mBold,
                    color: FwColor.white,
                  ),
                  onPressed: () async {
                    ModalLoadingRoute.showLoading(
                      Strings.pleaseWait,
                      context,
                    );
                    String privateKey = await ProvWalletFlutter.getPrivateKey(
                      words?.join(' ') ?? '',
                    );
                    final success = await ProvWalletFlutter.saveToWalletService(
                      words?.join(' ') ?? '',
                      accountName ?? '',
                      useBiometry: true,
                    );
                    ModalLoadingRoute.dismiss(context);

                    if (success) {
                      LocalAuthHelper.instance.enroll(
                        privateKey,
                        code?.join() ?? '',
                        accountName ?? '',
                        true,
                        context,
                        () async {
                          navigatorKey.currentState
                              ?.pushReplacement(Dashboard().route());
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwTextButton(
                  child: FwText(
                    Strings.later,
                    style: FwTextStyle.mBold,
                    color: FwColor.globalNeutral450,
                  ),
                  onPressed: () async {
                    ModalLoadingRoute.showLoading(
                      Strings.pleaseWait,
                      context,
                    );
                    String privateKey = await ProvWalletFlutter.getPrivateKey(
                      words?.join(' ') ?? '',
                    );
                    final success = await ProvWalletFlutter.saveToWalletService(
                      words?.join(' ') ?? '',
                      accountName ?? '',
                      useBiometry: false,
                    );
                    ModalLoadingRoute.dismiss(context);
                    if (success) {
                      LocalAuthHelper.instance.enroll(
                        privateKey,
                        code?.join() ?? '',
                        accountName ?? '',
                        false,
                        context,
                        () {
                          navigatorKey.currentState
                              ?.pushReplacement(Dashboard().route());
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 40,
              ),
              if (numberOfSteps != null)
                ProgressStepper(
                  currentStep ?? 0,
                  numberOfSteps ?? 1,
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
              if (numberOfSteps != null) VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }
}
