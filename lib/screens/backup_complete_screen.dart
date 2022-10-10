import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class BackupCompleteScreen extends StatelessWidget {
  const BackupCompleteScreen({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  final AddAccountFlowBloc bloc;

  static ValueKey keyContinueButton =
      ValueKey("$BackupCompleteScreen.continue_button");

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);

    return Scaffold(
      appBar: PwAppBar(
        title: strings.backupComplete,
        leadingIcon: PwIcons.back,
      ),
      body: PwOnboardingScreen(
        children: [
          VerticalSpacer.largeX6(),
          VerticalSpacer.largeX5(),
          PwText(
            strings.backupComplete.toUpperCase(),
            style: PwTextStyle.headline2,
            textAlign: TextAlign.center,
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
            ),
          ),
          VerticalSpacer.xxLarge(),
          Container(
            width: 180,
            alignment: Alignment.center,
            child: Image.asset(
              Assets.imagePaths.backupComplete,
              width: 180,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: PwButton(
              child: PwText(
                strings.continueName,
                key: BackupCompleteScreen.keyContinueButton,
                style: PwTextStyle.bodyBold,
                color: PwColor.neutralNeutral,
              ),
              onPressed: () async {
                await bloc.submitBackupComplete(context);
              },
            ),
          ),
          VerticalSpacer.largeX4(),
        ],
      ),
    );
  }
}
