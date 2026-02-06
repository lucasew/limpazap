import 'dart:io';

import 'package:flutter/foundation.dart';

import '../model/ArquivoDeletavelModel.dart';
import '../services/WhatsAppBackupService.dart';

class ArquivoDeletavelController {
  final WhatsAppBackupService _service;
  bool inverter;
  bool exibirUltimo;

  ArquivoDeletavelController({
    WhatsAppBackupService? service,
    this.inverter = false,
    this.exibirUltimo = false,
  }) : _service = service ?? WhatsAppBackupService();

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final allFiles = await _service.getBackupFiles();

    // Map files to the ArquivoDeletavel model asynchronously.
    final deletableFilesList = await Future.wait(
      allFiles.map(
        (file) => ArquivoDeletavel.load(
          file,
          isUltimo: !ArquivoDeletavel.regexBackup.hasMatch(file.path),
        ),
      ),
    );

    // Filter and sort.
    final deletableFiles = deletableFilesList
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

  /// Deletes a single file with safety checks.
  ///
  /// This method performs a TOCTOU check to ensure the file still exists
  /// and matches the backup regex before attempting deletion.
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

  Future<void> deleteFiles(List<ArquivoDeletavel> files) async {
    await Future.wait(files.map((file) => deleteFile(file)));
  }
}
