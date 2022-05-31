import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class RecoverAccountScreen extends StatelessWidget {
  RecoverAccountScreen({
    Key? key,
  }) : super(key: key);

  static final keyContinueButton =
      ValueKey('$RecoverAccountScreen.continue_button');

  final _bloc = get<AddAccountFlowBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: Strings.recoverAccount,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          _bloc.getCurrentStep(AddAccountScreen.recoverAccount),
          _bloc.totalSteps,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                VerticalSpacer.large(),
                PwText(
                  Strings.recoverAccount.toUpperCase(),
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
                    Strings.inTheFollowingStepsText,
                    style: PwTextStyle.body,
                    textAlign: TextAlign.center,
                  ),
                ),
                VerticalSpacer.xxLarge(),
                Image.asset(
                  Assets.imagePaths.recoverAccount,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: PwButton(
                    autofocus: true,
                    child: PwText(
                      Strings.continueName,
                      key: RecoverAccountScreen.keyContinueButton,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () {
                      _bloc.submitRecoverAccount();
                    },
                  ),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
