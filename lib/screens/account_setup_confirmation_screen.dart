import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class AccountSetupConfirmationBloc {
  void submitAccountSetupConfirmation();
}

class AccountSetupConfirmationScreen extends StatelessWidget {
  const AccountSetupConfirmationScreen({
    required AccountSetupConfirmationBloc bloc,
    Key? key,
  })  : _bloc = bloc,
        super(key: key);

  static final keyContinueButton =
      ValueKey('$AccountSetupConfirmationScreen.continue_button');

  final AccountSetupConfirmationBloc _bloc;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      appBar: PwAppBar(
        hasIcon: false,
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
                    VerticalSpacer.xxLarge(),
                    PwText(
                      strings.accountCreated,
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
                    VerticalSpacer.large(),
                    VerticalSpacer.medium(),
                    Container(
                      width: 180,
                      alignment: Alignment.center,
                      child: Image.asset(
                        Assets.imagePaths.accountFinished,
                        width: 180,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        key: keyContinueButton,
                        autofocus: true,
                        child: PwText(
                          strings.continueName,
                          style: PwTextStyle.subhead,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: _bloc.submitAccountSetupConfirmation,
                      ),
                    ),
                    VerticalSpacer.xxLarge(),
                    VerticalSpacer.xxLarge(),
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
