import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/image_placeholder.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingCustomizationSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
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
          child: FwText(
            Strings.trade,
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
            Strings.tradeHashText,
            style: FwTextStyle.m,
            textAlign: TextAlign.center,
            color: FwColor.globalNeutral550,
          ),
        ),
      ],
    );
  }
}
