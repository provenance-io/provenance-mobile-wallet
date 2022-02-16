import 'package:flutter_svg/svg.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class OnboardingCustomizationSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: viewportConstraints,
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
                    color: PwColor.white,
                  ),
                ),
                VerticalSpacer.largeX4(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetPaths.images.coins,
                      width: 180,
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
                    style: PwTextStyle.m_p,
                    textAlign: TextAlign.center,
                    color: PwColor.white,
                  ),
                ),
                VerticalSpacer.xxLarge(),
                VerticalSpacer.largeX5(),
              ],
            ),
          ),
        );
      },
    );
  }
}
