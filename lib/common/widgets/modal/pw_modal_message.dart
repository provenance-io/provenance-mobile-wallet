import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/assets.dart';

class PwModalMessage extends StatelessWidget {
  const PwModalMessage({
    required this.title,
    this.message,
    this.icon,
    this.actions,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? message;
  final Widget? icon;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagePaths.background),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Spacing.xxLarge,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PwText(
                      title,
                      style: PwTextStyle.headline2,
                      color: PwColor.neutralNeutral,
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) VerticalSpacer.large(),
                    if (message != null)
                      PwText(
                        message!,
                        style: PwTextStyle.body,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.center,
                      ),
                    if (icon != null) VerticalSpacer.xxLarge(),
                    if (icon != null) icon!,
                  ],
                ),
              ),
            ),
            if (actions != null) actions!,
            if (actions != null) VerticalSpacer.large(),
          ],
        ),
      ),
    );
  }
}
