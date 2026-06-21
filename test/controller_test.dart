import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:limpazap/services/WhatsAppBackupService.dart';

/// Minimal fake so getArquivos can be tested without Android storage APIs.
class _FakeBackupService extends WhatsAppBackupService {
  _FakeBackupService(this.files);
  final List<FileSystemEntity> files;

  @override
  Future<List<FileSystemEntity>> getBackupFiles() async => files;
}

void main() {
  group('ArquivoDeletavelController', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('limpazap_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<File> touch(String name, {Duration age = Duration.zero}) async {
      final file = File('${tempDir.path}/$name');
      await file.create();
      if (age != Duration.zero) {
        await file.setLastModified(DateTime.now().subtract(age));
      }
      return file;
    }

    test('deleteFile deletes a valid backup file', () async {
      final file = await touch('msgstore-2023.db');
      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(file);

      await controller.deleteFile(arquivoDeletavel);

      expect(await file.exists(), isFalse);
    });

    test('deleteFile does not delete a non-backup file', () async {
      final file = await touch('not-a-backup.db');
      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(file);

      await controller.deleteFile(arquivoDeletavel);

      expect(await file.exists(), isTrue);
    });

    test('getArquivos hides active db unless exibirUltimo', () async {
      final backup = await touch('msgstore-2023-01-01.db.crypt14');
      final active = await touch('msgstore.db.crypt14');
      final service = _FakeBackupService([backup, active]);

      final withoutActive = ArquivoDeletavelController(service: service);
      final listHidden = await withoutActive.getArquivos();
      expect(listHidden.length, 1);
      expect(listHidden.first.arquivo.path, backup.path);

      final withActive = ArquivoDeletavelController(
        service: service,
        exibirUltimo: true,
      );
      final listShown = await withActive.getArquivos();
      expect(listShown.length, 2);
    });

    test('getArquivos sorts by date and respects inverter', () async {
      final older = await touch(
        'msgstore-2023-01-01.db',
        age: const Duration(days: 2),
      );
      final newer = await touch(
        'msgstore-2023-01-02.db',
        age: const Duration(days: 1),
      );
      final service = _FakeBackupService([newer, older]);

      final asc = await ArquivoDeletavelController(service: service).getArquivos();
      expect(asc.map((a) => a.arquivo.path).toList(), [older.path, newer.path]);

      final desc = await ArquivoDeletavelController(
        service: service,
        inverter: true,
      ).getArquivos();
      expect(desc.map((a) => a.arquivo.path).toList(), [newer.path, older.path]);
    });
  });
}
