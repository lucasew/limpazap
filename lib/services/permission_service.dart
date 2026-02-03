import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests necessary storage permissions for the application.
  ///
  /// This handles:
  /// - `manageExternalStorage` for Android 11+
  /// - `storage` for older Android versions
  /// - Redirecting to settings if permissions are permanently denied.
  Future<void> requestPermissions() async {
    // Request `manageExternalStorage` first for modern Android versions.
    if (!await Permission.manageExternalStorage.status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    // Then, check for the general storage permission.
    if (await Permission.storage.status.isGranted) {
      return; // Exit if permission is granted.
    }

    // If storage permission is permanently denied, guide the user to settings.
    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    // Otherwise, request the storage permission.
    final status = await Permission.storage.request();
    // Use debugPrint to log permission status only in debug mode.
    debugPrint('Storage permission request result: $status');
  }
}
