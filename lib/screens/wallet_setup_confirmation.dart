import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/home/home_screen.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletSetupConfirmation extends StatelessWidget {
  const WalletSetupConfirmation({
    Key? key,
  }) : super(key: key);

  static final keyContinueButton =
      ValueKey('$WalletSetupConfirmation.continue_button');

  @override
  Widget build(BuildContext context) {
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
                      Strings.walletCreated,
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
                    VerticalSpacer.large(),
                    VerticalSpacer.medium(),
                    Container(
                      width: 180,
                      alignment: Alignment.center,
                      child: Image.asset(
                        Assets.imagePaths.walletFinished,
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
                        child: PwText(
                          Strings.continueName,
                          style: PwTextStyle.subhead,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: () async {
                          Navigator.pushAndRemoveUntil(
                            context,
                            HomeScreen().route(),
                            (route) => route.isFirst,
                          );
                        },
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
