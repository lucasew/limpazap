import 'dart:io';

class ArquivoDeletavel {
  final FileSystemEntity arquivo;
  late DateTime dataCriacao;
  late int tamanho;
  late bool isUltimo;
  ArquivoDeletavel(this.arquivo, {this.isUltimo = false}) {
    var stat = this.arquivo.statSync();
    this.dataCriacao = stat.modified;
    this.tamanho = stat.size;
  }
}
