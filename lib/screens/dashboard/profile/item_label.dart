import 'package:provenance_wallet/common/pw_design.dart';

class ItemLabel extends StatelessWidget {
  const ItemLabel({
    required this.text,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return PwText(
      text,
      style: PwTextStyle.body,
      overflow: TextOverflow.ellipsis,
    );
  }
}
