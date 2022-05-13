import 'dart:math';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/util/strings.dart';

typedef IsValidCallback = Future<bool> Function(String input);

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({
    Key? key,
    required this.isValidCallback,
  }) : super(key: key);

  final IsValidCallback isValidCallback;

  @override
  createState() => QRCodeScannerState();
}

class QRCodeScannerState extends State<QRCodeScanner> {
  QRCodeScannerState();

  bool _handled = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = '';
  MobileScannerController? controller;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.neutral800;

    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.close,
        color: background,
        title: Strings.qrScannerTitle,
      ),
      backgroundColor: background,
      body: Container(
        margin: EdgeInsets.only(
          bottom: Spacing.largeX6,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              key: qrKey,
              allowDuplicates: false,
              onDetect: _onDetect,
            ),
            ClipPath(
              clipper: InvertedClipper(),
              child: Container(
                color: background.withOpacity(.6),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onDetect(Barcode barcode, MobileScannerArguments? arguments) async {
    final data = barcode.rawValue;
    if (data != null) {
      final isValid = await widget.isValidCallback.call(data);
      if (isValid && !_handled) {
        _handled = true;
        Navigator.of(context).pop(data);
      }
    }
  }
}

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final side = min(size.width, size.height) - Spacing.largeX6;
    final xOffset = (size.width - side) / 2;
    final yOffset = (size.height - side) / 2;

    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(xOffset, yOffset, side, side))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
