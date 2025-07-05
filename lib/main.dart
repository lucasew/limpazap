import 'package:flutter/material.dart';
import 'view/ArquivosView.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checarPermissao() async {
    while (true) {
        if (!await Permission.manageExternalStorage.status.isGranted) {
          Permission.manageExternalStorage.request();
        }
        if (await Permission.storage.status.isGranted) {
            return;
        } else if (await Permission.storage.isPermanentlyDenied) {
            await openAppSettings();
        } else {
            print(await Permission.storage.request());
        }
    }
}

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kReleaseMode) {
        await WakelockPlus.enable();
    }
    checarPermissao();
    runApp(
            MaterialApp(home: ArquivosView())
    );
}

