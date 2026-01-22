import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';

void main() {
  group('ArquivoDeletavel', () {
    test('regexBackup should match msgstore-', () {
      expect(ArquivoDeletavel.regexBackup.hasMatch('msgstore-2022-01-01.db.crypt14'), isTrue);
      expect(ArquivoDeletavel.regexBackup.hasMatch('something-else.db'), isFalse);
    });
  });
}
