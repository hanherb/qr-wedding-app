import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_wedding/main.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        children: <Widget>[
          AppBar(
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('My App'),
          ),
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                  if (result != null)
                    Text('Barcode Type: QR - Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
              ]
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    var appState = context.watch<MyAppState>();
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _onQRScanned(result!.code, appState);
      });
    });
  }

  void _onQRScanned(String? resultCode, MyAppState appState) async {
    var checkIn = await appState.checkInEndpoint(resultCode);

    if (!context.mounted) return;

    if (checkIn.statusCode != 200) _showToast(context, 'Something went wrong');
  }

  void _showToast(BuildContext context, String msg) {

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(label: 'x', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}