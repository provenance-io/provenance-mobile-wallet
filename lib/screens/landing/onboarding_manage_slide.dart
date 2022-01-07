import 'package:flutter_tech_wallet/common/fw_design.dart';

class OnboardingManageSlide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnboardingManageSlideState();
  }
}

class _OnboardingManageSlideState extends State<OnboardingManageSlide> {
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
            'Manage your own wallet',
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
            'Fully control your wallet and crypto, and manage it independently.',
            style: FwTextStyle.m,
            textAlign: TextAlign.center,
            color: FwColor.globalNeutral550,
          ),
        ),
      ],
    );
  }
}
