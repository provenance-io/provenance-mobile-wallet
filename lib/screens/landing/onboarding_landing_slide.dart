import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_onboarding_view.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingLandingSlide extends StatelessWidget {
  const OnboardingLandingSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PwOnboardingView(
      bottomOffset: 0.0,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PwIcon(
              PwIcons.provenance,
              color: Theme.of(context).colorScheme.logo,
            ),
          ],
        ),
        VerticalSpacer.largeX3(),
        PwText(
          Strings.of(context).provenanceTitle,
          style: PwTextStyle.logo,
          textAlign: TextAlign.center,
          color: PwColor.neutralNeutral,
        ),
        VerticalSpacer.largeX5(),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: PwText(
            Strings.of(context).provenanceWalletDescription,
            style: PwTextStyle.m,
            textAlign: TextAlign.center,
            color: PwColor.neutralNeutral,
          ),
        ),
      ],
    );
  }
}
