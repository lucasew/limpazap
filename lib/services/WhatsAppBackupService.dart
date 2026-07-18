import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/error_handler.dart';

class WhatsAppBackupService {
  /// Relative path segments (from each external-storage root) where WhatsApp
  /// distributions store local encrypted database backups.
  ///
  /// Covers modern scoped-storage locations (`Android/media/<package>/…`) and
  /// the older top-level folders still present on many devices. Personal
  /// WhatsApp and WhatsApp Business each have both forms; GBWhatsApp only has
  /// the legacy layout.
  ///
  /// Exposed for unit tests so the scan set cannot silently drop a variant.
  static const databaseRelativePaths = [
    ['Android', 'media', 'com.whatsapp', 'WhatsApp', 'Databases'],
    [
      'Android',
      'media',
      'com.whatsapp.w4b',
      'WhatsApp Business',
      'Databases',
    ],
    ['WhatsApp', 'Databases'],
    // Legacy WhatsApp Business (pre-scoped-storage). Personal WhatsApp already
    // has a matching top-level entry above; Business was missing and backups
    // on that path were never listed.
    ['WhatsApp Business', 'Databases'],
    ['GBWhatsApp', 'Databases'],
  ];

  /// True when [entity] is a regular file whose name is a WhatsApp database
  /// (`msgstore.db.crypt*` active DB or `msgstore-*` historical backup).
  ///
  /// Exposed for unit tests; used when scanning Databases directories so non-DB
  /// entries never reach the controller/UI.
  static bool isWhatsAppDatabaseFile(FileSystemEntity entity) {
    if (entity is! File) {
      return false;
    }
    return p.basename(entity.path).startsWith('msgstore');
  }

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
        .expand((basePath) => databaseRelativePaths
            .map((parts) => p.joinAll([basePath, ...parts])))
        .toSet()
        .toList();

    // Asynchronously check existence then list files. Avoid existsSync/listSync
    // so a slow or large volume cannot freeze the UI isolate.
    final List<Future<List<FileSystemEntity>>> fileListFutures =
        pastas.map((path) async {
      final dir = Directory(path);
      try {
        if (!await dir.exists()) {
          return <FileSystemEntity>[];
        }
        // SECURITY-NOTE: Using async `list` prevents blocking the main thread,
        // which could lead to a client-side Denial of Service (DoS) if a
        // directory is very large or slow to access.
        // Only keep real WhatsApp database files (active msgstore.db.crypt* and
        // historical msgstore-* backups). Directories, .nomedia, and other
        // junk in Databases/ must not enter the delete pipeline.
        return await dir
            .list(followLinks: false)
            .where((entity) => isWhatsAppDatabaseFile(entity))
            .toList();
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
