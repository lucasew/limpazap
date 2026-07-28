import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
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
      final active = await temp.createFile(
        'msgstore.db.crypt15',
        modified: DateTime.utc(2024, 1, 3),
      );
      final backup = await temp.createFile(
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
      final mid = await temp.createFile(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );
      final oldest = await temp.createFile(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newest = await temp.createFile(
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
      final mid = await temp.createFile(
        'msgstore-2024-01-02.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 2),
      );
      final oldest = await temp.createFile(
        'msgstore-2024-01-01.1.db.crypt15',
        modified: DateTime.utc(2024, 1, 1),
      );
      final newest = await temp.createFile(
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
