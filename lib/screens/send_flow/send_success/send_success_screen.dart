import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class SendSuccessScreen extends StatelessWidget {
  const SendSuccessScreen({
    Key? key,
    required this.date,
    required this.totalAmount,
    required this.addressTo,
  }) : super(key: key);

  final DateTime date;
  final String totalAmount;
  final String addressTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagePaths.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.large,
        ),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VerticalSpacer.custom(
                    spacing: 110,
                  ),
                  Image.asset(
                    Assets.imagePaths.transactionComplete,
                    height: 80,
                    width: 80,
                  ),
                  VerticalSpacer.medium(),
                  PwText(
                    totalAmount,
                    style: PwTextStyle.display2,
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpacer.medium(),
                  PwText(
                    Strings.of(context).sendSuccessTransferDetailsBelow,
                    style: PwTextStyle.displayBody,
                  ),
                  VerticalSpacer.largeX5(),
                  SendReviewCell(
                    Strings.of(context).sendDate,
                    date.toIso8601String(),
                  ),
                  PwDivider(
                    indent: Spacing.xLarge,
                    endIndent: Spacing.xLarge,
                  ),
                  SendReviewCell(
                    Strings.of(context).sendTo,
                    addressTo,
                  ),
                  PwDivider(
                    indent: Spacing.xLarge,
                    endIndent: Spacing.xLarge,
                  ),
                  Expanded(child: Container()),
                  PwButton(
                    child: PwText(
                      Strings.of(context).sendDone,
                      style: PwTextStyle.bodyBold,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
