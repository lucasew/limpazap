import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './FilesWidget.dart';
import './NothingHereWidget.dart';
import './ForbiddenStorageWidget.dart';
import './PermissionModel.dart';
import './FilesModel.dart';

class DataHolderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return ScopedModelDescendant<PermissionModel>(
        builder: (context, child, model) {
      if (model.readExternalStoragePermission) {
        if (ScopedModel.of<FilesModel>(ctx).deletableFiles.length == 0) {
          return NothingHereWidget();
        }
        return FilesWidget();
      } else {
        return ForbiddenStorageWidget();
      }
    });
  }
}
