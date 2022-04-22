import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class BackupCompleteScreen extends StatelessWidget {
  const BackupCompleteScreen(
    this.flowType, {
    required this.words,
    this.accountName,
    this.currentStep,
    this.numberOfSteps,
    Key? key,
  }) : super(key: key);

  final List<String> words;
  final WalletAddImportType flowType;
  final String? accountName;
  final int? currentStep;
  final int? numberOfSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.backupComplete,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          currentStep ?? 0,
          numberOfSteps ?? 1,
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
                    VerticalSpacer.largeX6(),
                    VerticalSpacer.largeX5(),
                    PwText(
                      Strings.backupComplete.toUpperCase(),
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
                        Strings.theOnlyWayToRecoverYourAccount,
                        style: PwTextStyle.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    VerticalSpacer.xxLarge(),
                    Image.asset(
                      Assets.imagePaths.backupComplete,
                      width: 180,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        child: PwText(
                          Strings.continueName,
                          style: PwTextStyle.bodyBold,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: () async {
                          if (flowType == WalletAddImportType.onBoardingAdd) {
                            Navigator.of(context).push(CreatePin(
                              flowType,
                              words: words,
                              accountName: accountName,
                              currentStep: (currentStep ?? 0) + 1,
                              numberOfSteps: numberOfSteps,
                            ).route());
                          } else if (flowType ==
                              WalletAddImportType.dashboardAdd) {
                            ModalLoadingRoute.showLoading(
                              "",
                              context,
                            );

                            final chainId = await get<KeyValueService>()
                                    .getString(PrefKey.defaultChainId) ??
                                ChainId.defaultChainId;
                            final coin = ChainId.toCoin(chainId);

                            await get<WalletService>().addWallet(
                              phrase: words,
                              name: accountName ?? '',
                              coin: coin,
                            );
                            ModalLoadingRoute.dismiss(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
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
