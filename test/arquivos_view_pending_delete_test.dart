import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/model/ArquivoDeletavelModel.dart';
import 'package:limpazap/view/ArquivosView.dart';

void main() {
  group('withoutPendingDeletes', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('limpazap_pending_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<ArquivoDeletavel> loadNamed(String name) async {
      final file = File('${tempDir.path}/$name');
      await file.create();
      return ArquivoDeletavel.load(file);
    }

    test('returns the same list when nothing is pending', () async {
      final a = await loadNamed('msgstore-a.db');
      final b = await loadNamed('msgstore-b.db');
      final files = [a, b];

      final filtered = withoutPendingDeletes(files, <String>{});

      expect(identical(filtered, files), isTrue);
    });

    test('drops rows whose path is in the pending set', () async {
      final keep = await loadNamed('msgstore-keep.db');
      final drop = await loadNamed('msgstore-drop.db');

      final filtered = withoutPendingDeletes(
        [keep, drop],
        {drop.arquivo.path},
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.arquivo.path, keep.arquivo.path);
    });

    test('returns empty when every row is pending', () async {
      final only = await loadNamed('msgstore-only.db');

      final filtered = withoutPendingDeletes(
        [only],
        {only.arquivo.path},
      );

      expect(filtered, isEmpty);
    });
  });
}
