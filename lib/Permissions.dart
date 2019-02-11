import 'package:scoped_model/scoped_model.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/material.dart';
import './Files.dart';

class PermissionModel extends Model {
  bool _readExternalStoragePermission = false;
  ask() {
    SimplePermissions.checkPermission(Permission.WriteExternalStorage)
        .then((isAllowed) {
      if (isAllowed) {
        _readExternalStoragePermission = true;
      } else {
        SimplePermissions.requestPermission(Permission.WriteExternalStorage)
            .then((permState) {
          if (permState == PermissionStatus.authorized) {
            _readExternalStoragePermission = true;
          } else if (permState == PermissionStatus.deniedNeverAsk) {
            SimplePermissions.openSettings();
          }
        }).whenComplete(() => notifyListeners());
      }
    }).whenComplete(() => notifyListeners());
  }

  get readExternalStoragePermission => _readExternalStoragePermission;
}

class DataHolder extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    var permissionModel = PermissionModel()..ask();
    return ScopedModel<PermissionModel>(
        model: permissionModel,
        child: ScopedModelDescendant<PermissionModel>(
            builder: (context, child, model) {
          if (model.readExternalStoragePermission) {
            return FilesWidget();
          } else {
            return Center(
                child: Container(
                    child: Column(children: <Widget>[
              Text("Acesso\nNegado\nao\nArmazenamento!",
                  style: TextStyle(fontSize: 60), textAlign: TextAlign.center),
              RaisedButton(
                  child: Text("Tentar novamente"),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    permissionModel.ask();
                  })
            ])));
          }
        }));
  }
}
