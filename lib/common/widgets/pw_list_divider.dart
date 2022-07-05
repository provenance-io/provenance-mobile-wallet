import 'package:provenance_wallet/common/pw_design.dart';

class PwListDivider extends StatelessWidget {
  const PwListDivider({
    Key? key,
    this.indent,
    this.color,
  }) : super(key: key);

  PwListDivider.alternate({
    Key? key,
    this.indent,
    required BuildContext context,
  })  : color = Theme.of(context).colorScheme.neutral700,
        super(key: key);

  final double? indent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: indent,
      color: color ?? Theme.of(context).colorScheme.neutral600,
    );
  }
}
