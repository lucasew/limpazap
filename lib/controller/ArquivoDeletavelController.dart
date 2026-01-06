import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../model/ArquivoDeletavelModel.dart';

class ArquivoDeletavelController {
  // The name of old backups matches this regex.
  final dbAntigo = RegExp("msgstore-");
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

    // Convert paths to Directory objects and filter out non-existent ones.
    final existingDirectories =
        pastas.map((path) => Directory(path)).where((dir) => dir.existsSync());

    // List files from all existing directories, creating a single flat list.
    final allFiles = existingDirectories.expand((dir) {
      try {
        return dir.listSync();
      } on FileSystemException catch (e) {
        // Log the error and return an empty list to avoid crashing.
        // This can happen if the directory is inaccessible.
        debugPrint("Could not list files in ${dir.path}: $e");
        return <FileSystemEntity>[];
      }
    });

    // Map files to the ArquivoDeletavel model, identifying old backups.
    var deletableFiles = allFiles
        .map((file) =>
            ArquivoDeletavel(file, isUltimo: !dbAntigo.hasMatch(file.path)))
        // If 'exibirUltimo' is false, filter out the most recent backup.
        .where(
            (file) => this.exibirUltimo || dbAntigo.hasMatch(file.arquivo.path))
        .toList();

    // Sort files by creation date.
    deletableFiles.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));

    // Reverse the list if specified and return.
    return this.inverter ? deletableFiles.reversed.toList() : deletableFiles;
  }
}
