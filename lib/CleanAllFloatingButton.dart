import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './Files.dart';

class CleanAllFloatingButton extends StatelessWidget {
  Widget build(BuildContext ctx) => FloatingActionButton(
      onPressed: () {
        print("Apagar tudo");
        var snack = SnackBar(
            duration: Duration(seconds: 2),
            content: Text("Arquivos apagados!"));
        ScopedModel.of<FilesModel>(ctx, rebuildOnChange: true).deleteAll();
        Scaffold.of(ctx)
          ..removeCurrentSnackBar()
          ..showSnackBar(snack);
      },
      tooltip: "Limpar tudo",
      child: Icon(Icons.clear_all));
}
