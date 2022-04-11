import 'package:provenance_wallet/common/pw_design.dart';

class PwAutoSizineText extends StatelessWidget {
  const PwAutoSizineText(
    this.data, {
    this.height = 45,
    this.style = PwTextStyle.body,
    this.color,
    Key? key,
  }) : super(key: key);

  final String data;
  final double? height;
  final PwTextStyle style;
  final PwColor? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.fitWidth,
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
