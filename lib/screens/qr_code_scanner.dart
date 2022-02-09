import 'package:provenance_wallet/common/pw_design.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  QRCodeScanner();

  @override
  createState() => QRCodeScannerState();
}

class QRCodeScannerState extends State<QRCodeScanner> {
  QRCodeScannerState();

  bool _loading = true;
  bool _handled = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = '';
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.globalNeutral450,
        elevation: 0.0,
        leading: IconButton(
          icon: PwIcon(
            PwIcons.back,
            size: 24,
            color: Theme.of(context).colorScheme.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.globalNeutral450,
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

        return LoadingOverlay(
          isLoading: false,
          child: ClipRRect(
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
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   child: Container(
              //     height: 144 * ratio,
              //     color: Theme.of(context).colorScheme.background,
              //     child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Padding(
              //               padding: EdgeInsets.only(top: 40),
              //               child: FwText(
              //                 'Scan QR Code',
              //                 style: FwTextStyle.h3,
              //                 color: FwColor.black,
              //               )),
              //         ]),
              //   ),
              // ),
            ]),
          ),
        );
      },
    );
  }

  _handleQrData(String qrData) async {
    await controller?.pauseCamera();
    Map<String, dynamic> info = {};
    final isValid = await ProvWalletFlutter.isValidWalletConnectData(qrData);
    if (isValid && !_handled) {
      _handled = true;
      Navigator.of(context).pop(qrData);
    } else {
      controller?.resumeCamera();
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
