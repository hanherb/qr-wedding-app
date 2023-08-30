import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_wedding/model.dart';

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
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                  if (result != null)
                    Text('QR - Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
              ]
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  Future<(Invitation?, String)> checkInEndpoint(String? userId) async {
    final dio = Dio(
      BaseOptions(
        validateStatus: (status) => true,
      )
    );

    try {
      Response response = await dio.post('http://62.72.13.5/api/check-in/$userId');

      if (response.statusCode == 200) {
        return (Invitation.fromJson(response.data['data']), 'success');
      }
      else if (response.statusCode == 403) {
        var errMsg = response.data['error'].toString();
        return (null, errMsg);
      }
    }
    catch(err) {
      print(err);
      return (null, 'Something went wrong');
    }

    return (null, 'Something went wrong');
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _onQRScanned(result!.code);
      });
    });
  }

  void _onQRScanned(String? resultCode) async {
    var (checkIn, errMsg) = await checkInEndpoint(resultCode);
    if (!context.mounted) return;

    if (checkIn == null) {
      _failedDialog(context, errMsg);
    }
    else {
      _successDialog(context, checkIn);
    }

    await controller!.pauseCamera();
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

  void _successDialog(BuildContext context, Invitation payload) {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Center(child: Text("Welcome!")),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(payload.name, style: const TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(onPressed: () {
              controller!.resumeCamera();
              Navigator.of(context).pop();
            }, child: Text("Close")),
          )
        ],
      );
    });
  }

  void _failedDialog(BuildContext context, String msg) {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Center(child: Text("Sorry..")),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(msg))
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(onPressed: () {
              controller!.resumeCamera();
              Navigator.of(context).pop();
            }, child: Text("Close")),
          )
        ],
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}