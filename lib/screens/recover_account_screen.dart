import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class RecoverAccountBloc {
  void submitRecoverAccount();
}

class RecoverAccountScreen extends StatelessWidget {
  const RecoverAccountScreen({
    Key? key,
    required RecoverAccountBloc bloc,
  })  : _bloc = bloc,
        super(key: key);

  static final keyContinueButton =
      ValueKey('$RecoverAccountScreen.continue_button');

  final RecoverAccountBloc _bloc;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PwAppBar(
        title: strings.recoverAccount,
        leadingIcon: PwIcons.back,
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
                  strings.recoverAccount.toUpperCase(),
                  style: PwTextStyle.headline2,
                  textAlign: TextAlign.center,
                ),
                VerticalSpacer.large(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwText(
                    strings.inTheFollowingStepsText,
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
                      strings.continueName,
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
