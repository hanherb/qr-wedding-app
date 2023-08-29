import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_wedding/main.dart';
import 'package:qr_wedding/qr.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async { 
                  var checkIn = await appState.checkInEndpoint('A7SYDAS2');
                  if (!context.mounted) return;
                  if (checkIn == null) _showToast(context, 'Something went wrong');

                  // _checkCameraPermission(context);
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const QRViewExample(),
                  // ));
                },
                child: Text('Scan QR'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _checkCameraPermission(context) async {
    if (await Permission.camera.request().isGranted) {
      return;
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    print(statuses[Permission.camera]);

    return;
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
}