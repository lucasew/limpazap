import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './PermissionModel.dart';

class ForbiddenStorageWidget extends StatelessWidget {
  Widget build(BuildContext ctx) => Center(
          child: Container(
              child: Column(children: <Widget>[
        Text("Acesso\nNegado\nao\nArmazenamento!",
            style: TextStyle(fontSize: 60), textAlign: TextAlign.center),
        RaisedButton(
            child: Text("Tentar novamente"),
            color: Theme.of(ctx).accentColor,
            onPressed: () {
              ScopedModel.of<PermissionModel>(ctx).ask(); // Asks for permission
            })
      ])));
}
