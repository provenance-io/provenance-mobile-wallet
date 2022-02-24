import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/wallet_setup_confirmation.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';

class EnableFaceIdScreen extends StatelessWidget {
  const EnableFaceIdScreen({
    Key? key,
    required this.words,
    this.accountName,
    this.code,
    this.currentStep,
    this.numberOfSteps,
    this.flowType = WalletAddImportType.onBoardingAdd,
  }) : super(key: key);

  final List<String> words;
  final String? accountName;
  final List<int>? code;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.faceId,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: viewportConstraints,
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
                  VerticalSpacer.custom(
                    spacing: 104,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PwIcon(
                        PwIcons.face_id,
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                    ],
                  ),
                  VerticalSpacer.largeX4(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      Strings.useFaceIdTitle,
                      style: PwTextStyle.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwText(
                      Strings.useYourFaceId,
                      style: PwTextStyle.body,
                      textAlign: TextAlign.center,
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
                        color: PwColor.neutralNeutral,
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
                  VerticalSpacer.small(),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwTextButton(
                      child: PwText(
                        Strings.skipForNow,
                        style: PwTextStyle.subhead,
                        color: PwColor.neutralNeutral,
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
