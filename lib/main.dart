import 'package:flutter/material.dart';
import 'view/ArquivosView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() async {
  checar_permissao().then((_) => runApp(
    MaterialApp(home: ArquivosView())
  ));
}

Future<void> checar_permissao() async {
    if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
    }
    if (await Permission.storage.status.isGranted) {
        return;
    }
    var newState = Permission.storage.request();
    print(newState);
}
