import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/services/WhatsAppBackupService.dart';
import 'package:path/path.dart' as p;

void main() {
  group('WhatsAppBackupService.databaseRelativePaths', () {
    test('includes modern and legacy paths for personal and business WhatsApp',
        () {
      final joined = WhatsAppBackupService.databaseRelativePaths
          .map((parts) => p.joinAll(parts))
          .toSet();

      expect(
        joined,
        containsAll(<String>[
          p.joinAll(
              ['Android', 'media', 'com.whatsapp', 'WhatsApp', 'Databases']),
          p.joinAll([
            'Android',
            'media',
            'com.whatsapp.w4b',
            'WhatsApp Business',
            'Databases',
          ]),
          p.joinAll(['WhatsApp', 'Databases']),
          p.joinAll(['WhatsApp Business', 'Databases']),
          p.joinAll(['GBWhatsApp', 'Databases']),
        ]),
      );
    });

    test('every entry ends with Databases', () {
      for (final parts in WhatsAppBackupService.databaseRelativePaths) {
        expect(parts, isNotEmpty);
        expect(parts.last, 'Databases');
      }
    });
  });

  group('WhatsAppBackupService.isWhatsAppDatabaseFile', () {
    test('accepts historical msgstore- backup files', () {
      final file =
          File('/sdcard/WhatsApp/Databases/msgstore-2024-01-01.1.db.crypt15');
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isTrue);
    });

    test('accepts active msgstore.db.crypt* database', () {
      final file = File('/sdcard/WhatsApp/Databases/msgstore.db.crypt15');
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isTrue);
    });

    test('rejects non-msgstore files such as .nomedia', () {
      final file = File('/sdcard/WhatsApp/Databases/.nomedia');
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isFalse);
    });

    test('rejects directories even when named like a database', () {
      final dir = Directory('/sdcard/WhatsApp/Databases/msgstore-backup-dir');
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(dir), isFalse);
    });
  });

  group('WhatsAppBackupService.externalStorageRoot', () {
    test('strips app-scoped path from the first Android segment', () {
      final external = p.join(
        'storage',
        'emulated',
        '0',
        'Android',
        'data',
        'com.lucao.limpazap',
        'files',
      );
      expect(
        WhatsAppBackupService.externalStorageRoot(external),
        p.join('storage', 'emulated', '0'),
      );
    });

    test('returns path unchanged when Android is missing', () {
      final external = p.join('mnt', 'media_rw', 'ABCD-1234');
      expect(
        WhatsAppBackupService.externalStorageRoot(external),
        external,
      );
    });

    test('returns path unchanged when Android is the first segment', () {
      // androidIdx == 0 → keep input (cannot strip to empty parent).
      final external = p.join('Android', 'data', 'com.lucao.limpazap', 'files');
      expect(
        WhatsAppBackupService.externalStorageRoot(external),
        external,
      );
    });

    test('uses only the first Android segment when nested', () {
      final external = p.join(
        'storage',
        'emulated',
        '0',
        'Android',
        'data',
        'com.example',
        'files',
        'Android',
        'nested',
      );
      expect(
        WhatsAppBackupService.externalStorageRoot(external),
        p.join('storage', 'emulated', '0'),
      );
    });
  });
}
