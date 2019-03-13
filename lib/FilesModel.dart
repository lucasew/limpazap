import 'dart:core';
import 'dart:io';
import 'package:scoped_model/scoped_model.dart';

class FilesModel extends Model {
  static const List<String> _searchPaths = [
    "/storage/emulated/0/GBWhatsApp/Databases",
    "/storage/emulated/0/WhatsApp/Databases"
  ];
  static final garbageRegexp = RegExp(r"msgstore-");
  FilesModel() {
    notifyDelete(); // Initial tick
  }
  List<File> deletableFiles = [];
  update() async {
    deletableFiles = _searchPaths // Use the directory name array
        .map((d) => Directory(d)) // Convert to directory object
        .where((d) => d.existsSync()) // Filter only directories that exist
        .map((d) => d.listSync()) // ls them
        .expand((f) => f) // Flat the array
        .map((f) => File(f.path)) // Convert FileHandle to File
        .where((f) => garbageRegexp.hasMatch(f.path)) // Filter older backups
        .toList(); // Unlazy
  }

  notifyDelete() async {
    // Call me when deleting some file
    await update();
    notifyListeners();
  }
}
