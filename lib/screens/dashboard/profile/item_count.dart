import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class ItemCount extends StatelessWidget {
  const ItemCount({
    required this.count,
    Key? key,
  }) : super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.secondary250,
      ),
      padding: EdgeInsets.all(6),
      child: PwText(
        count.toString(),
        style: PwTextStyle.xsBold,
      ),
    );
  }
}
