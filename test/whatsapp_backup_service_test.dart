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
      final file = File(p.joinAll([
        p.separator,
        'sdcard',
        'WhatsApp',
        'Databases',
        'msgstore-2024-01-01.1.db.crypt15'
      ]));
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isTrue);
    });

    test('accepts active msgstore.db.crypt* database', () {
      final file = File(p.joinAll([
        p.separator,
        'sdcard',
        'WhatsApp',
        'Databases',
        'msgstore.db.crypt15'
      ]));
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isTrue);
    });

    test('rejects non-msgstore files such as .nomedia', () {
      final file = File(p.joinAll(
          [p.separator, 'sdcard', 'WhatsApp', 'Databases', '.nomedia']));
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(file), isFalse);
    });

    test('rejects directories even when named like a database', () {
      final dir = Directory(p.joinAll([
        p.separator,
        'sdcard',
        'WhatsApp',
        'Databases',
        'msgstore-backup-dir'
      ]));
      expect(WhatsAppBackupService.isWhatsAppDatabaseFile(dir), isFalse);
    });
  });
}
