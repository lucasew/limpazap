import 'package:flutter/material.dart';
import 'dart:async';

class SnackbarController {
  SnackBar snack;
  ScaffoldState scaffold;
  SnackbarController(ctx, this.snack) {
    scaffold = Scaffold.of(ctx);
  }

  show({afterMs: 0}) async {
    await Future.delayed(Duration(milliseconds: afterMs));
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(snack);
  }
}
