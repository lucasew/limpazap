import 'package:flutter/material.dart';
import 'view/ArquivosView.dart';
import 'core/permission_service.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kReleaseMode) {
    await WakelockPlus.enable();
  }
  await PermissionService.checarPermissao();
  runApp(const MaterialApp(title: 'Limpazap', home: ArquivosView()));
}
