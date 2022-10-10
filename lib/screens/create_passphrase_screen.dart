import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class CreatePassphraseScreen extends StatelessWidget {
  const CreatePassphraseScreen({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;

  static final keyContinueButton =
      ValueKey('$CreatePassphraseScreen.continue_button');

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      appBar: PwAppBar(
        title: strings.createPassphrase,
        leadingIcon: PwIcons.back,
      ),
      body: PwOnboardingScreen(
        children: [
          Expanded(
            child: Container(),
          ),
          PwText(
            strings.savePassphrase,
            style: PwTextStyle.headline2,
            textAlign: TextAlign.center,
          ),
          VerticalSpacer.large(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            child: PwText(
              strings.prepareToWriteDownYourRecoveryPhrase,
              style: PwTextStyle.body,
              textAlign: TextAlign.center,
              color: PwColor.neutral50,
            ),
          ),
          VerticalSpacer.large(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            child: PwText(
              strings.theOnlyWayToRecoverYourAccount,
              style: PwTextStyle.body,
              textAlign: TextAlign.center,
              color: PwColor.neutral50,
            ),
          ),
          Expanded(
            child: Container(),
          ),
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
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.large,
            ),
            child: PwText(
              strings.warningDoNotShare,
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
                strings.continueName,
                key: CreatePassphraseScreen.keyContinueButton,
                style: PwTextStyle.bodyBold,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () {
                bloc.submitCreatePassphrase();
              },
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
