import 'package:flutter_tech_wallet/common/fw_design.dart';

class FwDivider extends StatelessWidget with FwColorMixin {
  const FwDivider({
    this.color,
    this.indent,
    this.endIndent,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  final FwColor? color;

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
