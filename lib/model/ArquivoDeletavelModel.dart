import 'dart:io';

class ArquivoDeletavel {
  final FileSystemEntity arquivo;
  final DateTime dataCriacao;
  final int tamanho;
  final bool isUltimo;

  ArquivoDeletavel._(this.arquivo, this.dataCriacao, this.tamanho, this.isUltimo);

  /// Asynchronously loads file metadata to create an ArquivoDeletavel instance.
  /// This prevents blocking the UI thread with synchronous I/O operations.
  static Future<ArquivoDeletavel> load(FileSystemEntity arquivo, {bool isUltimo = false}) async {
    // SECURITY-NOTE: Use async `stat()` to avoid blocking the main thread,
    // ensuring the application remains responsive even with large file lists.
    final stat = await arquivo.stat();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }

  @Deprecated('Use ArquivoDeletavel.load instead to avoid blocking the UI thread.')
  factory ArquivoDeletavel(FileSystemEntity arquivo, {bool isUltimo = false}) {
    final stat = arquivo.statSync();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }
}
