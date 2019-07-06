import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'view/ArquivosView.dart';
import 'dart:io';

void main() async {
  checar_permissao().then((_) => runApp(MaterialApp(
            home: ArquivosView(),
          ) // MaterialApp
              ) // runApp
      ); // then
}

Future<void> checar_permissao() async {
  if (await SimplePermissions.checkPermission(Permission.WriteExternalStorage))
    return;
  if (await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage) ==
      PermissionStatus.authorized) return;
  await SimplePermissions.openSettings();
  exit(1);
}
