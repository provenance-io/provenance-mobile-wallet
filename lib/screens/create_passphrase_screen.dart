import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class CreatePassphraseScreen extends StatelessWidget {
  const CreatePassphraseScreen({
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final bloc = get<AddAccountFlowBloc>();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.createPassphrase,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          currentStep,
          totalSteps,
        ),
      ),
      body: PwOnboardingScreen(
        children: [
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
          Container(
            width: 180,
            alignment: Alignment.center,
            child: Image.asset(
              Assets.imagePaths.createPassphrase,
              width: 180,
            ),
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
                bloc.submitCreatePassphrase();
              },
            ),
          ),
          VerticalSpacer.largeX4(),
        ],
      ),
    );
  }
}
