import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service responsible for identifying and listing WhatsApp backup files on external storage.
///
/// This service handles the complexities of Android file storage, including:
/// *   Discovering external storage roots (internal storage and SD cards).
/// *   Constructing paths for various WhatsApp distributions (Standard, Business, GBWhatsApp).
/// *   Safely listing files without blocking the UI.
class WhatsAppBackupService {
  /// Scans all available external storage volumes for WhatsApp backup directories.
  ///
  /// This method performs a comprehensive scan by:
  /// 1.  Identifying all external storage roots using [getExternalStorageDirectories].
  /// 2.  Constructing potential backup paths for:
  ///     *   WhatsApp (com.whatsapp)
  ///     *   WhatsApp Business (com.whatsapp.w4b)
  ///     *   Legacy paths (WhatsApp/Databases, GBWhatsApp/Databases)
  /// 3.  Filtering for directories that actually exist.
  /// 4.  Asynchronously listing files in each directory to prevent UI jank.
  ///
  /// **Security:**
  /// *   Uses `path_provider` to avoid unreliable hardcoded paths like `/sdcard/`.
  /// *   Uses [p.join] to prevent path traversal vulnerabilities.
  /// *   Catches [FileSystemException] during listing to ensure robustness against permission issues or file system errors.
  ///
  /// Returns a flattened list of all [FileSystemEntity] objects found in the backup directories.
  /// Returns an empty list if no external storage is found or if no backups exist.
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

    // Convert paths to Directory objects and filter out non-existent ones.
    final existingDirectories = pastas
        .map((path) => Directory(path))
        .where((dir) => dir.existsSync());

    // Asynchronously list files from all directories.
    final List<Future<List<FileSystemEntity>>>
    fileListFutures = existingDirectories.map((dir) async {
      try {
        // SECURITY-NOTE: Using async `list` prevents blocking the main thread,
        // which could lead to a client-side Denial of Service (DoS) if a
        // directory is very large or slow to access.
        return await dir.list().toList();
      } on FileSystemException catch (e) {
        // Log the error and return an empty list to avoid crashing.
        debugPrint('Could not list files in ${dir.path}: $e');
        return <FileSystemEntity>[];
      }
    }).toList();

    // Wait for all file listing operations to complete and flatten the list.
    final allFileLists = await Future.wait(fileListFutures);
    return allFileLists.expand((fileList) => fileList).toList();
  }
}
