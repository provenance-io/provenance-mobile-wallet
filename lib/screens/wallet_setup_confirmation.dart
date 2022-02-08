import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/image_placeholder.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletSetupConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.white,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImagePlaceholder(),
                ],
              ),
              SizedBox(
                height: 48,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.yourWalletIsNowReadyToGo,
                  style: PwTextStyle.extraLarge,
                  textAlign: TextAlign.center,
                  color: PwColor.globalNeutral550,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.walletConfirmationSubtitleText,
                  style: PwTextStyle.m,
                  textAlign: TextAlign.center,
                  color: PwColor.globalNeutral550,
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
                    Strings.confirm,
                    style: PwTextStyle.mBold,
                    color: PwColor.white,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      Dashboard().route(),
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
              VerticalSpacer.custom(spacing: 56),
              VerticalSpacer.xxLarge(),
              VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }
}
