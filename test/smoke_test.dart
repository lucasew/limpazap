import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  test('backup regex distinguishes historical vs active db', () {
    expect(
      ArquivoDeletavel.regexBackup.hasMatch('/x/msgstore-2023-01-01.db.crypt14'),
      isTrue,
    );
    expect(
      ArquivoDeletavel.regexBackup.hasMatch('/x/msgstore.db.crypt14'),
      isFalse,
    );
  });
}
