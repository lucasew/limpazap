import 'dart:io';

class ArquivoDeletavel {
  final FileSystemEntity arquivo;
  final DateTime dataCriacao;
  final int tamanho;
  final bool isUltimo;

  ArquivoDeletavel._(this.arquivo, this.dataCriacao, this.tamanho, this.isUltimo);

  @Deprecated('Use ArquivoDeletavel.create instead to avoid blocking the UI thread')
  factory ArquivoDeletavel(FileSystemEntity arquivo, {bool isUltimo = false}) {
    final stat = arquivo.statSync();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }

  // SECURITY-NOTE: Use async factory to prevent blocking UI thread (DoS prevention)
  // when processing large numbers of files.
  static Future<ArquivoDeletavel> create(FileSystemEntity arquivo, {bool isUltimo = false}) async {
    final stat = await arquivo.stat();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }
}
