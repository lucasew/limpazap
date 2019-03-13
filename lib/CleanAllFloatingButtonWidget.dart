import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './FilesModel.dart';

class CleanAllFloatingButtonWidget extends StatelessWidget {
  Widget build(BuildContext ctx) => FloatingActionButton(
      onPressed: () {
        var snack = SnackBar(
            // Create snackbar
            duration: Duration(seconds: 2),
            content: Text("Arquivos apagados!"));
        var mdl = ScopedModel.of<FilesModel>(ctx); // Get the model from tree
        mdl.deletableFiles // Get deletable files
            .forEach((f) => f.deleteSync()); // And delete them
        mdl.notifyDelete(); // Then notify about it
        Scaffold.of(ctx) // Show snackbar
          ..removeCurrentSnackBar()
          ..showSnackBar(snack);
      },
      tooltip: "Limpar tudo",
      child: Icon(Icons.clear_all));
}
