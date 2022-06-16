import 'package:provenance_wallet/common/pw_design.dart';

class ColorKey extends StatelessWidget {
  const ColorKey({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      IconData(0xf5e1, fontFamily: 'MaterialIcons'),
      color: color,
      size: 10,
    );
  }
}
