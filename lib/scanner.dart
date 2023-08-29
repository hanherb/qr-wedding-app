import 'package:flutter/material.dart';
import 'package:qr_wedding/qr.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async { 
                  _checkCameraPermission(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRViewExample(),
                  ));
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
}