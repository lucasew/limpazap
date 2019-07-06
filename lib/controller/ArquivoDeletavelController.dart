import '../model/ArquivoDeletavelModel.dart';
import 'dart:io';

class ArquivoDeletavelController {
  ArquivoDeletavelController();
  static const pastas = [
    "/sdcard/WhatsApp/Databases",
    "/sdcard/GBWhatsApp/Databases"
  ];

  List<ArquivoDeletavel> get arquivos => pastas
      .map((p) => Directory(p)) // Transforma tudo em Directory
      .where((p) => p.existsSync()) // Filtra só os que existem
      .map((p) => p.listSync()) // Dá ls em todas as pastas
      .expand((att) => att) // Teremos uma lista de listas, agora não mais hehe
      .map((arq) => ArquivoDeletavel(arq)) // Gera model
      .toList(); // Expande o iterador
}
