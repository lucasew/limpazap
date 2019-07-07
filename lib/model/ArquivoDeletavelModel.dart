import 'dart:io';

class ArquivoDeletavel {
  final File arquivo;
  DateTime dataCriacao;
  int tamanho;
  bool isUltimo;
  ArquivoDeletavel(this.arquivo, {this.isUltimo: false}) {
    this.dataCriacao = this.arquivo.lastModifiedSync();
    this.tamanho = this.arquivo.lengthSync();
  }
}
