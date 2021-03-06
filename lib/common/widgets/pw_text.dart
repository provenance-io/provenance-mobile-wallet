import 'package:flutter/foundation.dart';
import 'package:provenance_wallet/common/pw_design.dart';

export '../pw_text_style.dart';

class PwText extends StatelessWidget
    with PwTextStyleMixin, PwColorMixin, Diagnosticable {
  const PwText(
    this.data, {
    Key? key,
    this.style = PwTextStyle.body,
    this.color,
    this.overflow,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.lineThrough = false,
    this.underline = false,
    this.textKey,
    this.softWrap,
  }) : super(key: key);

  /// The text to display.
  final String data;

  @override
  final PwTextStyle style;

  @override
  final PwColor? color;

  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool lineThrough;
  final bool underline;
  final Key? textKey;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: _getStyle(context),
      overflow: overflow,
      maxLines: maxLines,
      key: textKey,
      softWrap: softWrap,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      StringProperty('data', data),
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
