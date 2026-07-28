import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/controller/ArquivoDeletavelController.dart';

import 'support/temp_backup_dir.dart';

void main() {
  group('ArquivoDeletavelController.deleteFiles', () {
    final temp = TempBackupDir();

    setUp(() => temp.setUp(prefix: 'limpazap_delete_files_'));
    tearDown(() => temp.tearDown());

    test('deletes every historical backup in the batch', () async {
      final a = await temp.loadNamed('msgstore-2024-01-01.1.db.crypt15');
      final b = await temp.loadNamed('msgstore-2024-01-02.1.db.crypt15');
      final controller = ArquivoDeletavelController();

      await controller.deleteFiles([a, b]);

      expect(await a.arquivo.exists(), isFalse);
      expect(await b.arquivo.exists(), isFalse);
    });

    test('refuses active databases and non-backup names in the same batch',
        () async {
      final backup = await temp.loadNamed('msgstore-2024-01-01.1.db.crypt15');
      final active = await temp.loadNamed('msgstore.db.crypt15');
      final junk = await temp.loadNamed('not-a-backup.db');
      final controller = ArquivoDeletavelController();

      await controller.deleteFiles([backup, active, junk]);

      expect(await backup.arquivo.exists(), isFalse);
      expect(await active.arquivo.exists(), isTrue);
      expect(await junk.arquivo.exists(), isTrue);
    });

    test('no-ops on an empty batch', () async {
      final controller = ArquivoDeletavelController();
      await controller.deleteFiles(const []);
    });
  });
}
