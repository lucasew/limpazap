import 'dart:io';

/// Represents a WhatsApp database file found in storage.
///
/// This model encapsulates file metadata (like size and modification date)
/// to avoid repeated synchronous file system calls, which could block the UI.
/// Instances of this class are typically created via the [load] factory method.
class ArquivoDeletavel {
  /// Regular expression to identify backup files (e.g., `msgstore-2023-01-01...`).
  ///
  /// Files matching this pattern are considered historical backups.
  /// Files NOT matching this pattern are considered the active/latest database.
  /// Centralizing this pattern avoids code duplication and ensures consistency.
  static final RegExp regexBackup = RegExp('msgstore-');

  /// The underlying file system entity.
  final FileSystemEntity arquivo;

  /// The modification date of the file.
  final DateTime dataCriacao;

  /// The size of the file in bytes.
  final int tamanho;

  /// Indicates if this file is the active database (i.e., does not match the backup pattern).
  ///
  /// Usually corresponds to `msgstore.db.cryptXX`.
  final bool isUltimo;

  /// Private constructor to enforce asynchronous loading via [load].
  ArquivoDeletavel._(
    this.arquivo,
    this.dataCriacao,
    this.tamanho,
    this.isUltimo,
  );

  /// Asynchronously loads file metadata and creates an ArquivoDeletavel instance.
  ///
  /// This method uses [FileSystemEntity.stat] to retrieve file information without
  /// blocking the main isolate, which is crucial for maintaining UI responsiveness
  /// when processing a large number of backup files.
  static Future<ArquivoDeletavel> load(
    FileSystemEntity arquivo, {
    bool isUltimo = false,
  }) async {
    final stat = await arquivo.stat();
    return ArquivoDeletavel._(arquivo, stat.modified, stat.size, isUltimo);
  }
}
