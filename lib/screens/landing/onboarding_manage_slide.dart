import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

class OnboardingManageSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 158,
              width: 158,
              decoration: BoxDecoration(
                  color: Color(0xFF9196AA),
                  borderRadius: BorderRadius.all(Radius.circular(79))),
            )
          ],
        ),
        SizedBox(
          height: 48,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: FwText(
            Strings.manageYourOwnWallet,
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
            Strings.fullyControlYourWallet,
            style: FwTextStyle.m,
            textAlign: TextAlign.center,
            color: FwColor.globalNeutral550,
          ),
        ),
      ],
    );
  }
}
