import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  test('ArquivoDeletavel.load creates instance asynchronously', () async {
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/test_file.txt');
    await file.writeAsString('test content');

    // Use the async static factory method
    final model = await ArquivoDeletavel.load(file);

    expect(model.arquivo.path, equals(file.path));
    expect(model.tamanho, equals(12)); // "test content" is 12 bytes
    expect(model.isUltimo, isFalse);

    await tempDir.delete(recursive: true);
  });
}
