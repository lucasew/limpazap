import '../model/ArquivoDeletavelModel.dart';
import 'dart:io';

class ArquivoDeletavelController {
  final dbAntigo =
      RegExp("msgstore-"); // O nome dos backups antigos bate com esse aqui
  bool inverter;
  bool exibirUltimo;
  ArquivoDeletavelController({this.inverter: false, this.exibirUltimo: false});
  static const pastas = [
    "/sdcard/WhatsApp/Databases",
    "/sdcard/GBWhatsApp/Databases"
  ];

  List<ArquivoDeletavel> get arquivos {
    var ret = pastas
        .map((p) => Directory(p)) // Transforma tudo em Directory
        .where((p) => p.existsSync()) // Filtra só os que existem
        .map((p) => p.listSync()) // Dá ls em todas as pastas
        .expand(
            (att) => att) // Teremos uma lista de listas, agora não mais hehe
        .map((arq) => ArquivoDeletavel(arq,
            isUltimo: !dbAntigo.hasMatch(
                arq.path))) // Gera model verificando se é backup antigo ou não
        .where((a) =>
            this.exibirUltimo ||
            dbAntigo.hasMatch(
                a.arquivo.path)) // Ignora o ultimo backup se especificado
        .toList(); // Expande o iterador
    ret.sort(
        (x, y) => x.dataCriacao.compareTo(y.dataCriacao)); // Ordena todo mundo
    return this.inverter
        ? ret.reversed.toList()
        : ret; // Inverte se especificado e retorna
  }
}
