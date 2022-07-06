import 'package:provenance_wallet/common/pw_design.dart';

class PwListDivider extends StatelessWidget with PwColorMixin {
  const PwListDivider({
    Key? key,
    this.indent,
    this.color = PwColor.neutral600,
  }) : super(key: key);

  PwListDivider.alternate({
    Key? key,
    this.indent,
  })  : color = PwColor.neutral700,
        super(key: key);

  final double? indent;

  @override
  final PwColor color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: indent,
      color: getColor(context) ?? Theme.of(context).colorScheme.neutral600,
    );
  }
}
