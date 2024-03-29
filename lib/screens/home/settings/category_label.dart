import 'package:provenance_wallet/common/pw_design.dart';

class CategoryLabel extends StatelessWidget {
  const CategoryLabel(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.large,
      ),
      padding: EdgeInsets.only(
        top: Spacing.xxLarge,
        bottom: Spacing.large,
      ),
      child: PwText(
        text,
        style: PwTextStyle.subhead,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
