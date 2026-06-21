import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WhatsAppBackupService {
  /// Scans external storage for WhatsApp backup files.
  Future<List<FileSystemEntity>> getBackupFiles() async {
    // SECURITY: Use path_provider to avoid hardcoded paths.
    // Hardcoding `/sdcard/` is unreliable across Android versions.
    final List<Directory>? externalDirs = await getExternalStorageDirectories();
    if (externalDirs == null) {
      return [];
    }

    // SECURITY-NOTE: Using p.join prevents path traversal vulnerabilities
    // by ensuring that path components are correctly and safely combined.
    final pastas = externalDirs
        .map((dir) => dir.path.split('/Android/')[0])
        .expand(
          (basePath) => [
            p.join(
              basePath,
              'Android',
              'media',
              'com.whatsapp',
              'WhatsApp',
              'Databases',
            ),
            p.join(
              basePath,
              'Android',
              'media',
              'com.whatsapp.w4b',
              'WhatsApp Business',
              'Databases',
            ),
            p.join(basePath, 'WhatsApp', 'Databases'),
            p.join(basePath, 'GBWhatsApp', 'Databases'),
          ],
        )
        .toSet()
        .toList();

    // List files from directories that exist; skip missing paths without blocking.
    final fileListFutures = pastas.map((path) async {
      final dir = Directory(path);
      try {
        if (!await dir.exists()) {
          return <FileSystemEntity>[];
        }
        return await dir.list().toList();
      } on FileSystemException catch (e) {
        debugPrint('Could not list files in ${dir.path}: $e');
        return <FileSystemEntity>[];
      }
    });

    final allFileLists = await Future.wait(fileListFutures);
    return allFileLists.expand((fileList) => fileList).toList();
  }
}
