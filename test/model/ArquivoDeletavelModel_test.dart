import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  group('ArquivoDeletavel', () {
    late Directory tempDir;
    late File tempFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('limpazap_test');
      tempFile = File('${tempDir.path}/msgstore-2023-10-27.1.db.crypt14');
      await tempFile.create();
      // Write some data to give it a size
      await tempFile.writeAsString('hello world');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('Sync constructor initializes correctly (deprecated)', () {
      // ignore: deprecated_member_use
      final model = ArquivoDeletavel(tempFile, isUltimo: true);

      expect(model.arquivo.path, equals(tempFile.path));
      expect(model.tamanho, equals(11)); // 'hello world'.length
      expect(model.isUltimo, isTrue);
    });

    test('Async load initializes correctly', () async {
      final model = await ArquivoDeletavel.load(tempFile, isUltimo: true);

      expect(model.arquivo.path, equals(tempFile.path));
      expect(model.tamanho, equals(11));
      expect(model.isUltimo, isTrue);
      // We can't easily test dataCriacao exact match due to precision, but it should be close
      expect(model.dataCriacao.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });
  });
}
