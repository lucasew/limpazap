import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/services/WhatsAppBackupService.dart';

void main() {
  group('WhatsAppBackupService.isWhatsAppDatabaseFile', () {
    test('accepts historical msgstore- backup files', () {
      final file = File('/sdcard/WhatsApp/Databases/msgstore-2024-01-01.1.db.crypt15');
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
}
