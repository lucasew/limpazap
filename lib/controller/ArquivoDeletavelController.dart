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

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final pastas = await _pastas;

    // Convert paths to Directory objects and filter out non-existent ones.
    final existingDirectories =
        pastas.map((path) => Directory(path)).where((dir) => dir.existsSync());

    // Asynchronously list files from all directories.
    final List<Future<List<FileSystemEntity>>> fileListFutures =
        existingDirectories.map((dir) async {
      try {
        // SECURITY-NOTE: Using async `list` prevents blocking the main thread,
        // which could lead to a client-side Denial of Service (DoS) if a
        // directory is very large or slow to access.
        return await dir.list().toList();
      } on FileSystemException catch (e) {
        // Log the error and return an empty list to avoid crashing.
        debugPrint("Could not list files in ${dir.path}: $e");
        return <FileSystemEntity>[];
      }
    }).toList();

    // Wait for all file listing operations to complete and flatten the list.
    final allFileLists = await Future.wait(fileListFutures);
    final allFiles = allFileLists.expand((fileList) => fileList).toList();

    // Map files to the ArquivoDeletavel model, identifying old backups.
    // SECURITY-NOTE: Use async loading to prevent UI blocking (DoS risk).
    var deletableFilesFutures = allFiles.map((file) => ArquivoDeletavel.load(
        file,
        isUltimo: !dbAntigo.hasMatch(file.path)));
    var deletableFiles = (await Future.wait(deletableFilesFutures))
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
