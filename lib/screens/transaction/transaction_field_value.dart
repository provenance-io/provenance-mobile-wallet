import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class TransactionFieldValue extends StatelessWidget {
  const TransactionFieldValue({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Spacing.small,
      ),
      child: PwText(
        text,
        style: PwTextStyle.body,
        textAlign: TextAlign.right,
        color: PwColor.neutralNeutral,
      ),
    );
  }
}
