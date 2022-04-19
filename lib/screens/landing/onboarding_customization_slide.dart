import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_onboarding_view.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingCustomizationSlide extends StatelessWidget {
  const OnboardingCustomizationSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PwOnboardingView(children: [
      PwText(
        Strings.powerfulCustomization,
        style: PwTextStyle.headline1,
        textAlign: TextAlign.center,
        color: PwColor.neutralNeutral,
      ),
      VerticalSpacer.largeX4(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.images.coins,
            height: 180,
          ),
        ],
      ),
      VerticalSpacer.largeX5(),
      PwText(
        Strings.customizationDescription,
        style: PwTextStyle.m,
        textAlign: TextAlign.center,
        color: PwColor.neutralNeutral,
      ),
    ]);
  }
}
