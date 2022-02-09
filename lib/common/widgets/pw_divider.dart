import 'package:provenance_wallet/common/pw_design.dart';

class PwDivider extends StatelessWidget with PwColorMixin {
  const PwDivider({
    this.color,
    this.indent,
    this.endIndent,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  final PwColor? color;

  final double? indent;

  final double? endIndent;

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: getColor(context),
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      height: height,
    );
  }
}
