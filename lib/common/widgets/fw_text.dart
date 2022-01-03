import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';

import '../fw_text_style.dart';

export '../fw_text_style.dart';

class FwText extends StatelessWidget with FwTextStyleMixin, FwColorMixin {
  const FwText(
    this.data, {
    Key? key,
    this.style = FwTextStyle.m,
    this.color,
    this.overflow,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.lineThrough = false,
    this.underline = false,
  }) : super(key: key);

  /// The text to display.
  final String data;

  @override
  final FwTextStyle style;

  @override
  final FwColor? color;

  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool lineThrough;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: _getStyle(context),
      overflow: overflow,
      maxLines: maxLines,
    );
  }

  TextStyle? _getStyle(BuildContext context) {
    var style = color == null
        ? textStyle(context)
        : textStyle(context)?.copyWith(color: getColor(context));

    return lineThrough
        ? style?.copyWith(decoration: TextDecoration.lineThrough)
        : underline
            ? style?.copyWith(decoration: TextDecoration.underline)
            : style;
  }
}
