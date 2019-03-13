import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './CleanAllFloatingButtonWidget.dart';
import './DataHolderWidget.dart';
import './FilesModel.dart';
import './PermissionModel.dart';

var permission = PermissionModel();
var files = FilesModel();

void main() {
  permission.ask();
  runApp(ScopedModel<FilesModel>(
      model: files,
      child: // Files
          ScopedModel<PermissionModel>(
              model: permission,
              child: // Permission
                  App())));
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green),
        home: Scaffold(
            appBar:
                AppBar(title: Text("Limpador de WhatsApp"), actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: "Atualizar",
                  onPressed: () =>
                      ScopedModel.of<FilesModel>(ctx).notifyDelete())
            ]),
            body: Container(
                alignment: Alignment.bottomCenter,
                child: Material(child: DataHolderWidget())),
            floatingActionButton: CleanAllFloatingButtonWidget()));
  }
}
