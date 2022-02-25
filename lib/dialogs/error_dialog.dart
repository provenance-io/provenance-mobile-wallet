import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    Key? key,
    this.title,
    this.error,
    this.buttonText,
  }) : super(key: key);

  factory ErrorDialog.fromException(dynamic exception, {Key? key}) {
    final msg = exception.toString().replaceFirst(RegExp('^[^:]+: '), "");

    return ErrorDialog(
      key: key,
      error: msg,
    );
  }

  final String? title;
  final String? error;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                    ),
                    child: PwText(
                      title ?? Strings.unknownErrorTitle,
                      style: PwTextStyle.headline2,
                      textAlign: TextAlign.center,
                      color: PwColor.neutralNeutral,
                    ),
                  ),
                  VerticalSpacer.large(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                    ),
                    child: PwText(
                      error ?? Strings.somethingWentWrong,
                      style: PwTextStyle.body,
                      textAlign: TextAlign.center,
                      color: PwColor.neutralNeutral,
                    ),
                  ),
                  VerticalSpacer.xxLarge(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetPaths.images.warning,
                        height: 80,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwPrimaryButton.fromString(
                text: buttonText ?? Strings.okay,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            VerticalSpacer.largeX4(),
          ],
        ),
      ),
    );
  }
}
