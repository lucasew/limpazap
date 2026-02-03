import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';

class ArquivosWidget extends StatelessWidget {
  final List<ArquivoDeletavel> arquivos;
  final Function(ArquivoDeletavel) onDelete;

  const ArquivosWidget(this.arquivos, this.onDelete, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final widgets = arquivos.map((a) => ArquivoWidget(a, onDelete)).toList();
    return ListView(children: widgets);
  }
}
