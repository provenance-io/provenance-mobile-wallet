import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/settings/item_count.dart';
import 'package:provenance_wallet/screens/home/settings/item_label.dart';

class LinkItem extends StatelessWidget {
  const LinkItem({
    required this.text,
    required this.onTap,
    this.count,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function() onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.xxLarge,
        ),
        child: Row(
          children: [
            ItemLabel(
              text: text,
            ),
            if (count != null) ItemCount(count: count!),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(
                  right: Spacing.large,
                ),
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
