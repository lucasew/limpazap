import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/view/ArquivosView.dart';

import 'support/temp_backup_dir.dart';

void main() {
  group('withoutPendingDeletes', () {
    final temp = TempBackupDir();

    setUp(() => temp.setUp(prefix: 'limpazap_pending_'));
    tearDown(() => temp.tearDown());

    test('returns the same list when nothing is pending', () async {
      final a = await temp.loadNamed('msgstore-a.db');
      final b = await temp.loadNamed('msgstore-b.db');
      final files = [a, b];

      final filtered = withoutPendingDeletes(files, <String>{});

      expect(identical(filtered, files), isTrue);
    });

    test('drops rows whose path is in the pending set', () async {
      final keep = await temp.loadNamed('msgstore-keep.db');
      final drop = await temp.loadNamed('msgstore-drop.db');

      final filtered = withoutPendingDeletes(
        [keep, drop],
        {drop.arquivo.path},
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.arquivo.path, keep.arquivo.path);
    });

    test('returns empty when every row is pending', () async {
      final only = await temp.loadNamed('msgstore-only.db');

      final filtered = withoutPendingDeletes(
        [only],
        {only.arquivo.path},
      );

      expect(filtered, isEmpty);
    });
  });
}
