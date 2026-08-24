import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:limpazap/services/WhatsAppBackupService.dart';
import 'package:path/path.dart' as p;

import 'support/temp_backup_dir.dart';

/// Injectable stand-in so [ArquivoDeletavelController.getArquivos] can be
/// exercised without touching real external storage or path_provider.
class _FakeBackupService extends WhatsAppBackupService {
  _FakeBackupService(this._files);

  final List<FileSystemEntity> _files;

  @override
  Future<List<FileSystemEntity>> getBackupFiles() async => _files;
}

void main() {
  group('ArquivoDeletavelController.getArquivos', () {
    final temp = TempBackupDir();

    setUp(() => temp.setUp(prefix: 'limpazap_get_arquivos_'));
    tearDown(() => temp.tearDown());

    Future<List<ArquivoDeletavel>> loadArquivos(
      List<FileSystemEntity> files, {
      bool inverter = false,
      bool exibirUltimo = false,
    }) {
      return ArquivoDeletavelController(
        service: _FakeBackupService(files),
        inverter: inverter,
        exibirUltimo: exibirUltimo,
      ).getArquivos();
    }

    /// Mid / oldest / newest historical backups (shuffled creation order).
    Future<List<File>> threeHistoricalBackups() async {
      return [
        await temp.createFile(
          'msgstore-2024-01-02.1.db.crypt15',
          modified: DateTime.utc(2024, 1, 2),
        ),
        await temp.createFile(
          'msgstore-2024-01-01.1.db.crypt15',
          modified: DateTime.utc(2024, 1, 1),
        ),
        await temp.createFile(
          'msgstore-2024-01-03.1.db.crypt15',
          modified: DateTime.utc(2024, 1, 3),
        ),
      ];
    }

    List<String> basenames(List<ArquivoDeletavel> files) {
      return files.map((f) => p.basename(f.arquivo.path)).toList();
    }

    test('hides the active database when exibirUltimo is false', () async {
      final active = await temp.createFile(
        'msgstore.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );
      final older = await temp.createFile(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newer = await temp.createFile(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );

      final files = await loadArquivos([active, older, newer]);

      expect(files, hasLength(2));
      expect(basenames(files), [
        'msgstore-2024-01-01.1.db.crypt15',
        'msgstore-2024-01-02.1.db.crypt15',
      ]);
      expect(files.every((f) => !f.isUltimo), isTrue);
    });

    test('includes the active database when exibirUltimo is true', () async {
      final active = await temp.createFile(
        'msgstore.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );
      final backup = await temp.createFile(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );

      final files = await loadArquivos(
        [active, backup],
        exibirUltimo: true,
      );

      expect(files, hasLength(2));
      expect(
        files.where((f) => f.isUltimo).map((f) => p.basename(f.arquivo.path)),
        ['msgstore.db.crypt15'],
      );
    });

    test('sorts oldest first by default', () async {
      final files = await loadArquivos(await threeHistoricalBackups());

      expect(basenames(files), [
        'msgstore-2024-01-01.1.db.crypt15',
        'msgstore-2024-01-02.1.db.crypt15',
        'msgstore-2024-01-03.1.db.crypt15',
      ]);
    });

    test('sorts newest first when inverter is true', () async {
      final files = await loadArquivos(
        await threeHistoricalBackups(),
        inverter: true,
      );

      expect(basenames(files), [
        'msgstore-2024-01-03.1.db.crypt15',
        'msgstore-2024-01-02.1.db.crypt15',
        'msgstore-2024-01-01.1.db.crypt15',
      ]);
    });
  });
}
