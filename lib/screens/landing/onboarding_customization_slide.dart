import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingCustomizationSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: Spacing.xxLarge,
          ),
          child: PwText(
            Strings.powerfulCustomization,
            style: PwTextStyle.large,
            textAlign: TextAlign.center,
            color: PwColor.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetPaths.images.coins),
          ],
        ),
        VerticalSpacer.xxLarge(),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 98,
          ),
          child: PwText(
            Strings.customizationDescription,
            style: PwTextStyle.m_p,
            textAlign: TextAlign.center,
            color: PwColor.white,
          ),
        ),
      ],
    );
  }
}
