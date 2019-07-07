import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';
import 'dart:async';

class ArquivosWidget extends StatelessWidget {
  List<ArquivoDeletavel> arquivos;
  List<ArquivoWidget> widgets;
  StreamController<ArquivoDeletavel> chan;
  ArquivosWidget(this.arquivos, this.chan) {
    this.widgets = arquivos.map((a) => ArquivoWidget(a, chan)).toList();
  }
  Widget build(BuildContext ctx) {
    return ListView(children: widgets);
  }
}
