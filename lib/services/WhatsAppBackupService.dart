import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/error_handler.dart';

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
        .map((dir) => dir.path.split('${p.separator}Android${p.separator}')[0])
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
    final existingDirectories =
        pastas.map((path) => Directory(path)).where((dir) => dir.existsSync());

    // Asynchronously list files from all directories.
    final List<Future<List<FileSystemEntity>>> fileListFutures =
        existingDirectories.map((dir) async {
      try {
        // SECURITY-NOTE: Using async `list` prevents blocking the main thread,
        // which could lead to a client-side Denial of Service (DoS) if a
        // directory is very large or slow to access.
        return await dir.list().toList();
      } on FileSystemException catch (e, stackTrace) {
        // Log the error and return an empty list to avoid crashing.
        ErrorHandler.reportError(
            e, stackTrace, 'WhatsAppBackupService list files in ${dir.path}');
        return <FileSystemEntity>[];
      }
    }).toList();

    // Wait for all file listing operations to complete and flatten the list.
    final allFileLists = await Future.wait(fileListFutures);
    return allFileLists.expand((fileList) => fileList).toList();
  }
}
