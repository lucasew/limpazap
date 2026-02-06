import 'dart:io';

class ArquivoDeletavel {
  // Regex to identify WhatsApp backup files.
  // Centralizing this pattern avoids code duplication and ensures consistency.
  static final RegExp regexBackup = RegExp('msgstore-');

  final FileSystemEntity arquivo;
  final DateTime dataCriacao;
  final int tamanho;
  final bool isUltimo;

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
