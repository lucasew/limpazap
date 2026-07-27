import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ArquivoDeletavelController.deleteFiles', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('limpazap_delete_files_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<ArquivoDeletavel> loadNamed(String name) async {
      final file = File(p.join(tempDir.path, name));
      await file.create();
      return ArquivoDeletavel.load(
        file,
        isUltimo: !ArquivoDeletavel.isHistoricalBackup(file),
      );
    }

    test('deletes every historical backup in the batch', () async {
      final a = await loadNamed('msgstore-2024-01-01.1.db.crypt15');
      final b = await loadNamed('msgstore-2024-01-02.1.db.crypt15');
      final controller = ArquivoDeletavelController();

      await controller.deleteFiles([a, b]);

      expect(await a.arquivo.exists(), isFalse);
      expect(await b.arquivo.exists(), isFalse);
    });

    test('refuses active databases and non-backup names in the same batch',
        () async {
      final backup = await loadNamed('msgstore-2024-01-01.1.db.crypt15');
      final active = await loadNamed('msgstore.db.crypt15');
      final junk = await loadNamed('not-a-backup.db');
      final controller = ArquivoDeletavelController();

      await controller.deleteFiles([backup, active, junk]);

      expect(await backup.arquivo.exists(), isFalse);
      expect(await active.arquivo.exists(), isTrue);
      expect(await junk.arquivo.exists(), isTrue);
    });

    test('no-ops on an empty batch', () async {
      final controller = ArquivoDeletavelController();
      await controller.deleteFiles(const []);
    });
  });
}
