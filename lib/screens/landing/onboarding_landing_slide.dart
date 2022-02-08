import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingLandingSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PwIcon(
              PwIcons.provenance,
              // TODO: Put this in the theme once Figure colors are purged.
              color: Color(0xFF3F80F3),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 40,
          ),
          child: PwText(
            Strings.provenanceTitle,
            style: PwTextStyle.logo,
            textAlign: TextAlign.center,
            color: PwColor.white,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 64,
          ),
          child: PwText(
            Strings.provenanceWalletDescription,
            // TODO: Fix this style when Figure colors are purged.
            style: PwTextStyle.m_p,
            textAlign: TextAlign.center,
            color: PwColor.white,
          ),
        ),
      ],
    );
  }
}
