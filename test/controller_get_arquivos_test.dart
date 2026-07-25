import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/services/WhatsAppBackupService.dart';
import 'package:path/path.dart' as p;

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
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('limpazap_get_arquivos_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<File> createDb(String name, {required DateTime modified}) async {
      final file = File(p.join(tempDir.path, name));
      await file.create();
      await file.setLastModified(modified);
      return file;
    }

    test('hides the active database when exibirUltimo is false', () async {
      final active = await createDb(
        'msgstore.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );
      final older = await createDb(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newer = await createDb(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );

      final controller = ArquivoDeletavelController(
        service: _FakeBackupService([active, older, newer]),
      );

      final files = await controller.getArquivos();

      expect(files, hasLength(2));
      expect(
        files.map((f) => p.basename(f.arquivo.path)).toList(),
        [
          'msgstore-2024-01-01.1.db.crypt15',
          'msgstore-2024-01-02.1.db.crypt15',
        ],
      );
      expect(files.every((f) => !f.isUltimo), isTrue);
    });

    test('includes the active database when exibirUltimo is true', () async {
      final active = await createDb(
        'msgstore.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );
      final backup = await createDb(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );

      final controller = ArquivoDeletavelController(
        service: _FakeBackupService([active, backup]),
        exibirUltimo: true,
      );

      final files = await controller.getArquivos();

      expect(files, hasLength(2));
      expect(
        files.where((f) => f.isUltimo).map((f) => p.basename(f.arquivo.path)),
        ['msgstore.db.crypt15'],
      );
    });

    test('sorts oldest first by default', () async {
      final mid = await createDb(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );
      final oldest = await createDb(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newest = await createDb(
        'msgstore-2024-01-03.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );

      final controller = ArquivoDeletavelController(
        service: _FakeBackupService([mid, oldest, newest]),
      );

      final files = await controller.getArquivos();

      expect(
        files.map((f) => p.basename(f.arquivo.path)).toList(),
        [
          'msgstore-2024-01-01.1.db.crypt15',
          'msgstore-2024-01-02.1.db.crypt15',
          'msgstore-2024-01-03.1.db.crypt15',
        ],
      );
    });

    test('sorts newest first when inverter is true', () async {
      final mid = await createDb(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );
      final oldest = await createDb(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newest = await createDb(
        'msgstore-2024-01-03.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );

      final controller = ArquivoDeletavelController(
        service: _FakeBackupService([mid, oldest, newest]),
        inverter: true,
      );

      final files = await controller.getArquivos();

      expect(
        files.map((f) => p.basename(f.arquivo.path)).toList(),
        [
          'msgstore-2024-01-03.1.db.crypt15',
          'msgstore-2024-01-02.1.db.crypt15',
          'msgstore-2024-01-01.1.db.crypt15',
        ],
      );
    });
  });
}
