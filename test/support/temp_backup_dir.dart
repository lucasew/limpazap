import 'dart:io';

import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:path/path.dart' as p;

/// Shared temp directory + msgstore file factory for unit tests.
///
/// Several controller/view tests used to copy the same createTemp / tearDown /
/// create-file boilerplate. One helper keeps path joining and [isUltimo]
/// defaults consistent.
class TempBackupDir {
  late Directory dir;

  Future<void> setUp({String prefix = 'limpazap_test_'}) async {
    dir = await Directory.systemTemp.createTemp(prefix);
  }

  Future<void> tearDown() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Creates an empty file under [dir]. Optionally sets mtime for sort tests.
  Future<File> createFile(String name, {DateTime? modified}) async {
    final file = File(p.join(dir.path, name));
    await file.create(recursive: true);
    if (modified != null) {
      await file.setLastModified(modified);
    }
    return file;
  }

  /// Creates a file and loads it as [ArquivoDeletavel].
  ///
  /// When [isUltimo] is omitted, it matches production: historical `msgstore-`
  /// basenames are not active DBs.
  Future<ArquivoDeletavel> loadNamed(
    String name, {
    bool? isUltimo,
    DateTime? modified,
  }) async {
    final file = await createFile(name, modified: modified);
    return ArquivoDeletavel.load(
      file,
      isUltimo: isUltimo ?? !ArquivoDeletavel.isHistoricalBackup(file),
    );
  }
}
