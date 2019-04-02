import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './DeletableFileWidget.dart';
import './FilesModel.dart';

class FilesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return SingleChildScrollView(
        child: ScopedModelDescendant<FilesModel>(
            builder: (contextFile, childFile, modelFile) => Column(
                children: modelFile.deletableFiles
                    .map((f) => DeletableFileWidget(f)) // Transforma no widget
                    .toList()))); // Transforma em lista
  }
}
