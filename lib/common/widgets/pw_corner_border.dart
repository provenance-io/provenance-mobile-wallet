import 'package:provenance_blockchain_wallet/common/pw_design.dart';

enum CapType { round, square }

class _PwCornerCustomPainter extends CustomPainter {
  _PwCornerCustomPainter(
    CapType capType,
    double width,
    Color color,
  ) {
    _paint = Paint();
    _paint.strokeWidth = width;
    _paint.color = color;
    _paint.style = PaintingStyle.stroke;

    _paint.strokeCap =
        capType == CapType.round ? StrokeCap.round : StrokeCap.square;
  }

  late Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final hDimen = size.width / 3;
    final vDimen = size.height / 3;

    canvas.drawLine(
      Offset(0, 0),
      Offset(hDimen, 0),
      _paint,
    );
    canvas.drawLine(
      Offset(2 * hDimen, 0),
      Offset(size.width, 0),
      _paint,
    );

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, vDimen),
      _paint,
    );
    canvas.drawLine(
      Offset(size.width, 2 * vDimen),
      Offset(size.width, size.height),
      _paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(2 * hDimen, size.height),
      _paint,
    );
    canvas.drawLine(
      Offset(hDimen, size.height),
      Offset(0, size.height),
      _paint,
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, 2 * vDimen),
      _paint,
    );
    canvas.drawLine(
      Offset(0, vDimen),
      Offset(0, 0),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_PwCornerCustomPainter oldDelegate) {
    return oldDelegate._paint.strokeWidth != _paint.strokeWidth ||
        oldDelegate._paint.color != _paint.color ||
        oldDelegate._paint.strokeCap != _paint.strokeCap;
  }
}

class PwCornerBorder extends StatelessWidget {
  const PwCornerBorder({
    required this.child,
    this.width = 2,
    this.color,
    this.capType = CapType.square,
    Key? key,
  }) : super(key: key);
  final Color? color;
  final Widget child;
  final double width;
  final CapType capType;

  @override
  Widget build(BuildContext context) {
    var mergedColor = color;
    if (mergedColor == null) {
      final theme = Theme.of(context);
      mergedColor = theme.indicatorColor;
    }

    return CustomPaint(
      painter: _PwCornerCustomPainter(
        capType,
        width,
        mergedColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(width / 2),
        child: child,
      ),
    );
  }
}
