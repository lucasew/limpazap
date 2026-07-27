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
    // Bottom inset so the last large-type rows clear the parent FAB
    // (ArquivosView bulk-delete). Without this, the sweep button covers
    // the size/date labels on the final items.
    return ListView.builder(
      itemCount: arquivos.length,
      padding: const EdgeInsets.only(bottom: 88),
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
