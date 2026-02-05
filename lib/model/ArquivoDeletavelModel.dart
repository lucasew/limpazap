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

  factory ArquivoDeletavel(FileSystemEntity arquivo, {bool isUltimo = false}) {
    final stat = arquivo.statSync();
    return ArquivoDeletavel._(arquivo, stat.modified, stat.size, isUltimo);
  }
}
