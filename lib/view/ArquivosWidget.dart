import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';
import 'dart:async';

class ArquivosWidget extends StatelessWidget {
  final List<ArquivoDeletavel> arquivos;
  final StreamController<ArquivoDeletavel> chan;
  const ArquivosWidget(this.arquivos, this.chan, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final widgets = arquivos.map((a) => ArquivoWidget(a, chan)).toList();
    return ListView(children: widgets);
  }
}
