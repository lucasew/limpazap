import 'dart:io';

class ArquivoDeletavel {
  final File arquivo;
  DateTime data_criacao;
  int tamanho;
  ArquivoDeletavel(this.arquivo) {
    this.data_criacao = this.arquivo.lastModifiedSync();
    this.tamanho = this.arquivo.lengthSync();
  }

  apagar() async => (await this.arquivo.delete()).exists();
}
