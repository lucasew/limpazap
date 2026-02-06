import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../services/WhatsAppBackupService.dart';

class ArquivoDeletavelController {
  final WhatsAppBackupService _service = WhatsAppBackupService();
  bool inverter;
  bool exibirUltimo;
  ArquivoDeletavelController({
    this.inverter = false,
    this.exibirUltimo = false,
  });

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final allFiles = await _service.getBackupFiles();

    // Map files to the ArquivoDeletavel model, identifying old backups.
    final deletableFiles = allFiles
        .map(
          (file) => ArquivoDeletavel(
            file,
            isUltimo: !ArquivoDeletavel.regexBackup.hasMatch(file.path),
          ),
        )
        // If 'exibirUltimo' is false, filter out the most recent backup.
        .where(
          (file) =>
              exibirUltimo ||
              ArquivoDeletavel.regexBackup.hasMatch(file.arquivo.path),
        )
        .toList();

    // Sort files by creation date.
    deletableFiles.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));

    // Reverse the list if specified and return.
    return inverter ? deletableFiles.reversed.toList() : deletableFiles;
  }

  Future<void> deleteFile(ArquivoDeletavel file) async {
    // SECURITY-NOTE: Re-verify the file path and existence before deleting
    // to mitigate a Time-of-check to Time-of-use (TOCTOU) race condition.
    // This ensures we only delete expected backup files.
    if (ArquivoDeletavel.regexBackup.hasMatch(file.arquivo.path) &&
        await file.arquivo.exists()) {
      try {
        await file.arquivo.delete();
      } on FileSystemException catch (e) {
        // Log if deletion fails for any reason (e.g., permissions).
        debugPrint('Failed to delete ${file.arquivo.path}: $e');
      }
    }
  }

  /// Deletes multiple files in parallel using [Future.wait].
  /// This ensures that all deletion operations are initiated concurrently.
  Future<void> deleteFiles(List<ArquivoDeletavel> files) async {
    await Future.wait(files.map(deleteFile));
  }
}
