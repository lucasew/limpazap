import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';
import 'dart:async';

class ArquivosWidget extends StatelessWidget {
  List<ArquivoDeletavel> arquivos;
  StreamController<ArquivoDeletavel> chan;
  ArquivosWidget(this.arquivos, this.chan);
  Widget build(BuildContext ctx) {
    Future.delayed(Duration(milliseconds: 500)).then((_) => Scaffold.of(ctx)
            .showSnackBar(SnackBar(
                    content:
                        Text("${arquivos.length} arquivos encontrados!") // Text
                    ) // SnackBar
                ) // showSnackBar
        ); // then
    return ListView(
        children: this
            .arquivos
            .map((a) => ArquivoWidget(a, chan)) // map
            .toList() // toList
        );
  }
}
