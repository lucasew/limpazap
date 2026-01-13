import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
    // SECURITY-NOTE: Using p.join prevents path traversal vulnerabilities
    // by ensuring that path components are correctly and safely combined.
    return externalDirs
        .map((dir) => dir.path.split('/Android/')[0])
        .expand((basePath) => [
              p.join(basePath, "Android", "media", "com.whatsapp", "WhatsApp", "Databases"),
              p.join(basePath, "Android", "media", "com.whatsapp.w4b", "WhatsApp Business", "Databases"),
              p.join(basePath, "WhatsApp", "Databases"),
              p.join(basePath, "GBWhatsApp", "Databases"),
            ])
        .toSet()
        .toList();
  }

  Iterable<FileSystemEntity> _getAllFiles(Iterable<Directory> directories) {
    return directories.expand((dir) {
      try {
        return dir.listSync();
      } on FileSystemException catch (e) {
        debugPrint("Could not list files in ${dir.path}: $e");
        return <FileSystemEntity>[];
      }
    });
  }

  List<ArquivoDeletavel> _mapAndFilterFiles(Iterable<FileSystemEntity> files) {
    return files
        .map((file) =>
            ArquivoDeletavel(file, isUltimo: !dbAntigo.hasMatch(file.path)))
        .where(
            (file) => this.exibirUltimo || dbAntigo.hasMatch(file.arquivo.path))
        .toList();
  }

  List<ArquivoDeletavel> _sortFiles(List<ArquivoDeletavel> files) {
    files.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));
    return this.inverter ? files.reversed.toList() : files;
  }

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final pastas = await _pastas;
    final existingDirectories =
        pastas.map((path) => Directory(path)).where((dir) => dir.existsSync());

    final allFiles = _getAllFiles(existingDirectories);
    final deletableFiles = _mapAndFilterFiles(allFiles);
    final sortedFiles = _sortFiles(deletableFiles);

    return sortedFiles;
  }
}
