import 'dart:io';

class ArquivoDeletavel {
  final FileSystemEntity arquivo;
  final DateTime dataCriacao;
  final int tamanho;
  final bool isUltimo;

  ArquivoDeletavel._(this.arquivo, this.dataCriacao, this.tamanho, this.isUltimo);

  @Deprecated('Use ArquivoDeletavel.load() instead to avoid blocking the UI thread')
  factory ArquivoDeletavel(FileSystemEntity arquivo, {bool isUltimo = false}) {
    final stat = arquivo.statSync();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }

  // SECURITY: Use async factory to prevent blocking UI thread with statSync
  static Future<ArquivoDeletavel> load(FileSystemEntity arquivo, {bool isUltimo = false}) async {
    final stat = await arquivo.stat();
    return ArquivoDeletavel._(
      arquivo,
      stat.modified,
      stat.size,
      isUltimo,
    );
  }
}
