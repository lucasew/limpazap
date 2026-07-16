import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  group('ArquivoDeletavel.isHistoricalBackup', () {
    test('matches historical backup file names', () {
      final file = File('/sdcard/WhatsApp/Databases/msgstore-2024-01-01.1.db.crypt15');
      expect(ArquivoDeletavel.isHistoricalBackup(file), isTrue);
    });

    test('does not match active database file names', () {
      final file = File('/sdcard/WhatsApp/Databases/msgstore.db.crypt15');
      expect(ArquivoDeletavel.isHistoricalBackup(file), isFalse);
    });

    test('ignores msgstore- in parent directory segments', () {
      // Full-path matching would false-positive here and treat the active DB
      // as a deletable backup.
      final file = File(
        '/sdcard/msgstore-exports/WhatsApp/Databases/msgstore.db.crypt15',
      );
      expect(ArquivoDeletavel.isHistoricalBackup(file), isFalse);
    });
  });

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

    test('deleteFile deletes a valid backup file', () async {
      final file = File('${tempDir.path}/msgstore-2023.db');
      await file.create();

      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(file);

      await controller.deleteFile(arquivoDeletavel);

      expect(await file.exists(), isFalse);
    });

    test('deleteFile does not delete a non-backup file', () async {
      final file = File('${tempDir.path}/not-a-backup.db');
      await file.create();

      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(file);

      await controller.deleteFile(arquivoDeletavel);

      // Should still exist because basename is not a historical backup
      expect(await file.exists(), isTrue);
    });

    test('deleteFile does not delete active DB when parent path has msgstore-',
        () async {
      final trickyDir =
          await Directory('${tempDir.path}/msgstore-exports').create();
      final file = File('${trickyDir.path}/msgstore.db.crypt15');
      await file.create();

      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(
        file,
        isUltimo: !ArquivoDeletavel.isHistoricalBackup(file),
      );

      expect(arquivoDeletavel.isUltimo, isTrue);
      await controller.deleteFile(arquivoDeletavel);

      expect(await file.exists(), isTrue);
    });
  });
}
