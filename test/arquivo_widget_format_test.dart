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

  group('formatBackupSize', () {
    test('shows bytes below 1 KB', () {
      expect(formatBackupSize(0), '0 B');
      expect(formatBackupSize(512), '512 B');
      expect(formatBackupSize(999), '999 B');
    });

    test('shows KB for small backups instead of 0 MB', () {
      // Old always-MB rounding: 200000 / 1e6 = 0.2 → 0 MB.
      expect(formatBackupSize(200000), '200 KB');
      expect(formatBackupSize(1000), '1 KB');
      expect(formatBackupSize(999999), '1000 KB');
    });

    test('shows MB for typical WhatsApp backups', () {
      expect(formatBackupSize(1000000), '1 MB');
      expect(formatBackupSize(45000000), '45 MB');
      expect(formatBackupSize(999999999), '1000 MB');
    });

    test('shows GB for very large files', () {
      expect(formatBackupSize(1000000000), '1 GB');
      expect(formatBackupSize(2500000000), '3 GB');
    });

    test('clamps negative sizes to zero', () {
      expect(formatBackupSize(-1), '0 B');
    });
  });
}
