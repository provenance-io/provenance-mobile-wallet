import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/image_placeholder.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/wallet_setup_confirmation.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';

class EnableFaceId extends StatelessWidget {
  EnableFaceId({
    required this.words,
    this.accountName,
    this.code,
    this.currentStep,
    this.numberOfSteps,
    this.flowType = WalletAddImportType.onBoardingAdd,
  });

  final List<String> words;
  final String? accountName;
  final List<int>? code;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: PwText(
          Strings.useFaceId,
          style: PwTextStyle.h5,
          textAlign: TextAlign.left,
          color: PwColor.globalNeutral550,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              height: 66,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImagePlaceholder(),
              ],
            ),
            SizedBox(
              height: 36,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwText(
                Strings.useYourFaceId,
                style: PwTextStyle.m,
                textAlign: TextAlign.center,
                color: PwColor.globalNeutral550,
              ),
            ),
            Expanded(child: Container()),
            SizedBox(
              height: 24,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwButton(
                child: PwText(
                  Strings.enable,
                  style: PwTextStyle.mBold,
                  color: PwColor.white,
                ),
                onPressed: () async {
                  ModalLoadingRoute.showLoading(
                    Strings.pleaseWait,
                    context,
                  );

                  final success = await get<WalletService>().saveWallet(
                    phrase: words,
                    name: accountName ?? '',
                    useBiometry: true,
                  );

                  ModalLoadingRoute.dismiss(context);

                  if (success) {
                    LocalAuthHelper.instance.enroll(
                      code?.join() ?? '',
                      accountName ?? '',
                      true,
                      context,
                      () async {
                        Navigator.of(context)
                            .push(WalletSetupConfirmation().route());
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
              child: PwTextButton(
                child: PwText(
                  Strings.later,
                  style: PwTextStyle.mBold,
                  color: PwColor.globalNeutral450,
                ),
                onPressed: () async {
                  ModalLoadingRoute.showLoading(
                    Strings.pleaseWait,
                    context,
                  );

                  final success = await get<WalletService>().saveWallet(
                    phrase: words,
                    name: accountName ?? '',
                    useBiometry: false,
                  );

                  ModalLoadingRoute.dismiss(context);
                  if (success) {
                    LocalAuthHelper.instance.enroll(
                      code?.join() ?? '',
                      accountName ?? '',
                      false,
                      context,
                      () {
                        Navigator.of(context)
                            .push(WalletSetupConfirmation().route());
                      },
                    );
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
