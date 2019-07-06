import 'package:flutter/material.dart';
import 'dart:async';

class SnackbarController {
  SnackBar snack;
  ScaffoldState scaffold;
  SnackbarController(BuildContext ctx, this.snack) {
    scaffold = Scaffold.of(ctx);
  }

  show() async {
    await Future.delayed(Duration(milliseconds: 500));
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(snack);
  }
}
