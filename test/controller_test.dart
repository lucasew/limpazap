import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

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

      // Should still exist because regex 'msgstore-' does not match
      expect(await file.exists(), isTrue);
    });
  });
}
