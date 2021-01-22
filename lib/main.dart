import 'package:flutter/material.dart';
import 'view/ArquivosView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await checar_permissao();
  runApp(
    MaterialApp(home: ArquivosView())
  );
}

Future<void> checar_permissao() async {
    while (true) {
        if (await Permission.storage.status.isGranted) {
            return;
        } else if (await Permission.storage.isPermanentlyDenied) {
            await openAppSettings();
        } else {
            print(await Permission.storage.request());
        }
    }
}
