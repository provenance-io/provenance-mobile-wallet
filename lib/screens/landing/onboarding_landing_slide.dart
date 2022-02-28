import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingLandingSlide extends StatelessWidget {
  const OnboardingLandingSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
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
          Strings.provenanceTitle,
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
            Strings.provenanceWalletDescription,
            style: PwTextStyle.mP,
            textAlign: TextAlign.center,
            color: PwColor.neutralNeutral,
          ),
        ),
        VerticalSpacer.largeX6(),
        VerticalSpacer.largeX5(),
      ],
    );
  }
}
