import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        leadingIcon: PwIcons.back,
        color: Theme.of(context).colorScheme.neutral450,
      ),
      backgroundColor: Theme.of(context).colorScheme.neutral450,
      body: _buildBody(context),
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

  _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = constraints.maxHeight / 600;

        return ClipRRect(
          child: Stack(children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 144 * ratio,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.red,
                        borderRadius: 0,
                        borderLength: 0,
                        borderWidth: 0,
                        cutOutSize: 300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  _handleQrData(String qrData) async {
    await controller?.pauseCamera();
    final isValid = await widget.isValidCallback.call(qrData);
    if (isValid && !_handled) {
      _handled = true;
      Navigator.of(context).pop(qrData);
    } else {
      await controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _handleQrData(scanData.code);
      });
    });
  }
}
