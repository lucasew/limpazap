import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import './ArquivoWidget.dart';

class ArquivosWidget extends StatelessWidget {
  final List<ArquivoDeletavel> arquivos;
  final Function(ArquivoDeletavel) onDelete;

  /// Forwarded to each [ArquivoWidget]; false disables swipe-delete for the
  /// whole list (e.g. while bulk delete is running).
  final bool allowDelete;

  const ArquivosWidget(
    this.arquivos,
    this.onDelete, {
    this.allowDelete = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: arquivos.length,
      itemBuilder: (context, index) {
        return ArquivoWidget(
          arquivos[index],
          onDelete,
          allowDelete: allowDelete,
        );
      },
    );
  }
}
