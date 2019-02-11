import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './DeletableFile.dart';

class FilesModel extends Model {
  static const List<String> _searchPaths = [
    "/storage/emulated/0/GBWhatsApp/Databases",
    "/storage/emulated/0/WhatsApp/Databases"
  ];
  List<File> get files => _searchPaths // Pega as pastas pra procurar
      .map((d) => Directory(d)) // Transforma tudo no dito objeto
      .where((d) => d.existsSync()) // Deixa só as que existem
      .map((d) => d.listSync()) // Dá ls nelas
      .expand((f) => f) // Transforma numa lista de File uma dimensão
      .map((f) => File(f.path)) // Transforma em File
      .where((f) =>
          RegExp(r"msgstore-").hasMatch(f.path)) // Só deixa os backups antigos
      .toList(); // Tira preguiça

  deleteFile(File f) {
    print("Deletado: ${f.path}");
    if (f.existsSync()) {
      f.deleteSync();
    }
    notifyListeners();
  }

  deleteAll() {
    files.forEach((f) => deleteFile(f));
  }
}

class FilesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return ScopedModelDescendant<FilesModel>(
        builder: (contextFile, childFile, modelFile) => Column(
            children: modelFile.files
                .map((f) => DeletableFile(f)) // Transforma no widget
                .toList())); // Transforma em lista
  }
}
