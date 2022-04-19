import 'package:provenance_wallet/common/pw_design.dart';

class PwAutoSizingText extends StatelessWidget {
  const PwAutoSizingText(
    this.data, {
    this.height = 45,
    this.style = PwTextStyle.body,
    this.color,
    this.fit = BoxFit.fitHeight,
    Key? key,
  }) : super(key: key);

  final String data;
  final double? height;
  final PwTextStyle style;
  final PwColor? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FittedBox(
        alignment: Alignment.center,
        fit: fit,
        child: PwText(
          (data.isNotEmpty) ? data : " ",
          style: style,
          color: color,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
