import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/ArquivoDeletavelModel.dart';

class ArquivoDeletavelController {
  final dbAntigo =
      RegExp("msgstore-"); // O nome dos backups antigos bate com esse aqui
  bool inverter;
  bool exibirUltimo;
  ArquivoDeletavelController({this.inverter = false, this.exibirUltimo = false});

  Future<List<String>> get _pastas async {
    // SECURITY: Use path_provider to avoid hardcoded paths.
    // Hardcoding `/sdcard/` is unreliable across Android versions.
    final List<Directory>? externalDirs = await getExternalStorageDirectories();
    if (externalDirs == null) {
      return [];
    }

    return externalDirs
        .map((dir) => dir.path.split('/Android/')[0])
        .expand((basePath) => [
              "$basePath/Android/media/com.whatsapp/WhatsApp/Databases",
              "$basePath/Android/media/com.whatsapp.w4b/WhatsApp Business/Databases",
              "$basePath/WhatsApp/Databases",
              "$basePath/GBWhatsApp/Databases",
            ])
        .toSet()
        .toList();
  }

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final pastas = await _pastas;
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
