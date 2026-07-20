import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/view/ArquivoWidget.dart';

void main() {
  group('formatBackupDateTime', () {
    test('zero-pads day, month, hour, and minute', () {
      final d = DateTime(2024, 1, 2, 3, 4);
      expect(formatBackupDateTime(d), '02.01.2024 03:04');
    });

    test('keeps double-digit fields unchanged', () {
      final d = DateTime(2024, 11, 23, 15, 45);
      expect(formatBackupDateTime(d), '23.11.2024 15:45');
    });
  });

  group('isSwipeDeleteEnabled', () {
    test('allows swipe only for historical backups when deletes are allowed',
        () {
      expect(
        isSwipeDeleteEnabled(isUltimo: false, allowDelete: true),
        isTrue,
      );
    });

    test('never allows swipe on the active database', () {
      expect(
        isSwipeDeleteEnabled(isUltimo: true, allowDelete: true),
        isFalse,
      );
    });

    test('blocks swipe on backups while allowDelete is false (bulk busy)', () {
      expect(
        isSwipeDeleteEnabled(isUltimo: false, allowDelete: false),
        isFalse,
      );
    });
  });
}
