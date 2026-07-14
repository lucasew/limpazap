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

    Future<void> _createControllerAndFile(String fileName) async {
      final file = File('${tempDir.path}/$fileName');
      await file.create();

      final controller = ArquivoDeletavelController();
      final arquivoDeletavel = await ArquivoDeletavel.load(file);

      await controller.deleteFile(arquivoDeletavel);
    }

    test('deleteFile deletes a valid backup file', () async {
      await _createControllerAndFile('msgstore-2023.db');
      final file = File('${tempDir.path}/msgstore-2023.db');
      expect(await file.exists(), isFalse);
    });

    test('deleteFile does not delete a non-backup file', () async {
      await _createControllerAndFile('not-a-backup.db');
      final file = File('${tempDir.path}/not-a-backup.db');
      // Should still exist because regex 'msgstore-' does not match
      expect(await file.exists(), isTrue);
    });
  });
}
