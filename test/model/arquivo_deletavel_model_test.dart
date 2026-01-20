import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  test('ArquivoDeletavel.load loads metadata asynchronously', () async {
    final tempDir = Directory.systemTemp.createTempSync('limpazap_test');
    final file = File('${tempDir.path}/msgstore-2024-01-01.db.crypt14');
    file.createSync();

    final model = await ArquivoDeletavel.load(file);

    expect(model.arquivo.path, equals(file.path));
    expect(model.tamanho, equals(0));
    expect(model.isUltimo, isFalse);

    file.deleteSync();
    tempDir.deleteSync();
  });
}
