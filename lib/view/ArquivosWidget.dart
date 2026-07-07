import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';

class ArquivosWidget extends StatelessWidget {
  final List<ArquivoDeletavel> arquivos;
  final Function(ArquivoDeletavel) onDelete;
  const ArquivosWidget(this.arquivos, this.onDelete, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: arquivos.length,
      itemBuilder: (context, index) {
        return ArquivoWidget(arquivos[index], onDelete);
      },
    );
  }
}
