import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/main.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard.dart';

class WalletSetupConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 158,
                    width: 158,
                    decoration: BoxDecoration(
                      color: Color(0xFF9196AA),
                      borderRadius: BorderRadius.all(Radius.circular(79)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 48,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwText(
                  "Your wallet is now ready to go.",
                  style: FwTextStyle.extraLarge,
                  textAlign: TextAlign.center,
                  color: FwColor.globalNeutral550,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwText(
                  "Lorem ipsum dolor sit amet",
                  style: FwTextStyle.m,
                  textAlign: TextAlign.center,
                  color: FwColor.globalNeutral550,
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: FwButton(
                  child: FwText(
                    "Confirm",
                    style: FwTextStyle.mBold,
                    color: FwColor.white,
                  ),
                  onPressed: () {
                    navigatorKey.currentState
                        ?.pushReplacement(Dashboard().route());
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
