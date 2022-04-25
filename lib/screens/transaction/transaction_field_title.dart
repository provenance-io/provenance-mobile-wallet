import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class TransactionFieldTitle extends StatelessWidget {
  const TransactionFieldTitle({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: Spacing.small,
      ),
      child: PwText(
        text,
        color: PwColor.neutralNeutral,
        style: PwTextStyle.body,
      ),
    );
  }
}
