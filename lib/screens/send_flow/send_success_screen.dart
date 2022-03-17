import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_wallet/util/assets.dart';

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
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AssetPaths.images.transactionComplete,
              height: 80,
              width: 80,
            ),
            VerticalSpacer.medium(),
            PwText(
              totalAmount,
              style: PwTextStyle.display2,
            ),
            VerticalSpacer.medium(),
            PwText(
              "Your transfer details are below",
              style: PwTextStyle.displayBody,
            ),
            VerticalSpacer.largeX5(),
            SendReviewCell(
              "Date",
              date.toIso8601String(),
            ),
            PwDivider(
              indent: Spacing.xLarge,
              endIndent: Spacing.xLarge,
            ),
            SendReviewCell(
              "To",
              addressTo,
            ),
            PwDivider(
              indent: Spacing.xLarge,
              endIndent: Spacing.xLarge,
            ),
          ],
        ),
      ),
    );
  }
}
