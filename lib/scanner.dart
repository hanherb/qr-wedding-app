import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_wedding/main.dart';
import 'package:qr_wedding/qr.dart';

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
                  var checkIn = await appState.checkInEndpoint('4HQZFN19');

                  if (!context.mounted) return;

                  if (checkIn.statusCode != 200) _showToast(context, 'Something went wrong');
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