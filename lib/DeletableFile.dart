import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart' as path;
import './Files.dart';

class DeletableFile extends StatelessWidget {
  DeletableFile(this.file);
  final File file;

  String labelFileSize(File file) {
    var size = file.lengthSync();
    String r;
    if (size < pow(1000, 1)) r = size.toString() + "B";
    if (size < pow(1000, 2))
      r = (size / pow(1000, 1)).round().toString() + "KB";
    if (size < pow(1000, 3))
      return r = (size / pow(1000, 2)).round().toString() + "MB";
    if (size < pow(1000, 4))
      return r = (size / pow(1000, 3)).round().toString() + "GB";
    return r;
  }

  @override
  Widget build(BuildContext ctx) {
    return Card(
        color: Colors.green[2],
        child: Row(children: [
          Flexible(
              child: Text(path.basename(this.file.path),
                  overflow: TextOverflow.fade, style: TextStyle(fontSize: 36))),
          Text(labelFileSize(this.file), style: TextStyle(fontSize: 30)),
          IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                var snackbar = SnackBar(content: Text("Deletado $file"));
                ScopedModel.of<FilesModel>(ctx, rebuildOnChange: true)
                    .deleteFile(this.file);
                Scaffold.of(ctx)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(snackbar);
              })
        ]));
  }
}
