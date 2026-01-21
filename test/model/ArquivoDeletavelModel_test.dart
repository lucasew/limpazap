import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  test('ArquivoDeletavel.load creates instance asynchronously', () async {
    // Create a temporary file for testing
    final tempDir = Directory.systemTemp.createTempSync();
    final file = File('${tempDir.path}/test_file.txt');
    file.writeAsStringSync('test content');

    // Use the async load method
    final model = await ArquivoDeletavel.load(file, isUltimo: true);

    // Verify properties
    expect(model.arquivo.path, equals(file.path));
    expect(model.tamanho, greaterThan(0));
    expect(model.isUltimo, isTrue);

    // Cleanup
    tempDir.deleteSync(recursive: true);
  });
}
