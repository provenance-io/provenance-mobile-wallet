import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_screen.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

// TODO: On init, activate notifications.

class WalletSetupConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.provenanceNeutral750,
        elevation: 0.0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.provenanceNeutral750,
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
                    Image.asset(
                      AssetPaths.images.walletFinished,
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
                          style: PwTextStyle.subhead,
                          color: PwColor.white,
                        ),
                        onPressed: () async {
                          Navigator.pushAndRemoveUntil(
                            context,
                            DashboardScreen().route(),
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
