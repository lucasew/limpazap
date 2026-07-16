import 'dart:io';

import '../model/ArquivoDeletavelModel.dart';
import '../services/WhatsAppBackupService.dart';
import '../core/error_handler.dart';

/// Manages the retrieval, filtering, and deletion of WhatsApp backup files.
///
/// This controller orchestrates interactions between the [WhatsAppBackupService]
/// and the UI, handling asynchronous data loading and performing safety checks
/// before file operations.
class ArquivoDeletavelController {
  final WhatsAppBackupService _service;

  /// Whether to reverse the sort order of the file list.
  bool inverter;

  /// Whether to include the active database (the "latest" file) in the list.
  bool exibirUltimo;

  /// Creates a new controller instance.
  ///
  /// [service] can be injected for testing purposes.
  /// [inverter] defaults to false (oldest first).
  /// [exibirUltimo] defaults to false (hide active database).
  ArquivoDeletavelController({
    WhatsAppBackupService? service,
    this.inverter = false,
    this.exibirUltimo = false,
  }) : _service = service ?? WhatsAppBackupService();

  /// Fetches backup files, loads their metadata, and applies filtering rules.
  ///
  /// The process involves:
  /// 1. Retrieving file paths from the [WhatsAppBackupService].
  /// 2. Asynchronously loading metadata (size, date) for all files in parallel.
  /// 3. Filtering files based on the [exibirUltimo] flag and backup regex.
  /// 4. Sorting files by creation date (and optionally reversing based on [inverter]).
  ///
  /// Returns a list of [ArquivoDeletavel] ready for display.
  Future<List<ArquivoDeletavel>> getArquivos() async {
    final allFiles = await _service.getBackupFiles();

    // Map files to the ArquivoDeletavel model asynchronously.
    // isUltimo is derived from the file *name* only (see isHistoricalBackup).
    final deletableFilesList = await Future.wait(
      allFiles.map(
        (file) => ArquivoDeletavel.load(
          file,
          isUltimo: !ArquivoDeletavel.isHistoricalBackup(file),
        ),
      ),
    );

    // Filter using the isUltimo flag already computed at load time (avoids a
    // second regex pass that could drift from ArquivoDeletavel.load).
    final deletableFiles = deletableFilesList
        .where((file) => exibirUltimo || !file.isUltimo)
        .toList();

    // Sort by date in one pass; inverter flips the comparator so we do not
    // allocate a reversed copy of the list.
    deletableFiles.sort(
      (a, b) => inverter
          ? b.dataCriacao.compareTo(a.dataCriacao)
          : a.dataCriacao.compareTo(b.dataCriacao),
    );
    return deletableFiles;
  }

  /// Deletes a single file with safety checks.
  ///
  /// This method performs a TOCTOU check to ensure the file still exists
  /// and matches the backup regex before attempting deletion.
  Future<void> deleteFile(ArquivoDeletavel file) async {
    // SECURITY-NOTE: Re-verify basename + existence before deleting to mitigate
    // TOCTOU and to refuse the active DB even if a parent path contains
    // `msgstore-` (full-path matching used to allow that false positive).
    if (ArquivoDeletavel.isHistoricalBackup(file.arquivo) &&
        await file.arquivo.exists()) {
      try {
        await file.arquivo.delete();
      } on FileSystemException catch (e, stackTrace) {
        // Log if deletion fails for any reason (e.g., permissions).
        ErrorHandler.reportError(e, stackTrace, 'ArquivoDeletavelController delete ${file.arquivo.path}');
      }
    }
  }

  /// Deletes multiple files concurrently.
  ///
  /// This method iterates through the provided list of [files] and calls
  /// [deleteFile] for each one. Using [Future.wait] ensures that deletions
  /// happen in parallel for better performance.
  Future<void> deleteFiles(List<ArquivoDeletavel> files) async {
    await Future.wait(files.map((file) => deleteFile(file)));
  }
}
