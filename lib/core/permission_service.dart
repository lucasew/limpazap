import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> checarPermissao() async {
    // Android 11+: all-files access is what reaches WhatsApp Databases outside
    // app-specific storage. If we already have it (or the user just granted it),
    // do not fall through to legacy storage checks — those can still be denied
    // and would incorrectly open system settings.
    if (await Permission.manageExternalStorage.status.isGranted) {
      return;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return;
    }

    // Older Android / fallback when all-files access is unavailable.
    if (await Permission.storage.status.isGranted) {
      return;
    }

    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    final status = await Permission.storage.request();
    debugPrint('Storage permission request result: $status');
  }
}
