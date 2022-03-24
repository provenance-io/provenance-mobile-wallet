import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingCustomizationSlide extends StatelessWidget {
  const OnboardingCustomizationSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints.tight(MediaQuery.of(context).size),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: PwText(
                Strings.powerfulCustomization,
                style: PwTextStyle.headline1,
                textAlign: TextAlign.center,
                color: PwColor.neutralNeutral,
              ),
            ),
            VerticalSpacer.largeX4(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetPaths.images.coins,
                  height: 180,
                ),
              ],
            ),
            VerticalSpacer.largeX5(),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: PwText(
                Strings.customizationDescription,
                style: PwTextStyle.m,
                textAlign: TextAlign.center,
                color: PwColor.neutralNeutral,
              ),
            ),
            VerticalSpacer.xxLarge(),
            VerticalSpacer.largeX5(),
          ],
        ),
      ),
    );
  }
}
