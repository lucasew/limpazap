import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:path/path.dart' as p;

void main() {
  test('ArquivoDeletavel.create creates instance asynchronously with correct stats', () async {
    final tempDir = await Directory.systemTemp.createTemp('test_dir');
    final tempFile = File(p.join(tempDir.path, 'test_file.txt'));
    await tempFile.writeAsString('content');

    final arquivo = await ArquivoDeletavel.create(tempFile);

    expect(arquivo.arquivo.path, tempFile.path);
    expect(arquivo.tamanho, 7); // "content" length
    expect(arquivo.isUltimo, false);

    // Clean up
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ArquivoDeletavel.create respects isUltimo flag', () async {
    final tempDir = await Directory.systemTemp.createTemp('test_dir_2');
    final tempFile = File(p.join(tempDir.path, 'test_file_2.txt'));
    await tempFile.writeAsString('content');

    final arquivo = await ArquivoDeletavel.create(tempFile, isUltimo: true);

    expect(arquivo.isUltimo, true);

    // Clean up
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
}
