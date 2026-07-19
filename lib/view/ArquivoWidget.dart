import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';

/// Formats a backup timestamp for the large-type list row.
///
/// Day, month, hour, and minute are zero-padded so labels stay the same
/// width while scrolling (e.g. `01.01.2024 09:05` instead of `1.1.2024 9:05`).
@visibleForTesting
String formatBackupDateTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final Function(ArquivoDeletavel) onDelete;
  const ArquivoWidget(this.arquivo, this.onDelete, {super.key});

  String get _textoDataCriacao => formatBackupDateTime(arquivo.dataCriacao);

  String get _textoTamanho {
    return '${(arquivo.tamanho / 1000000).round()} MB';
  }

  Widget _buildTitle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 50),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Icon(arquivo.isUltimo ? Icons.warning : Icons.history, size: 36),
            Text(_textoDataCriacao, style: const TextStyle(fontSize: 36)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: <Widget>[
        const Icon(Icons.sd_card, size: 36),
        Text(_textoTamanho, style: const TextStyle(fontSize: 28)),
      ],
    );
  }

  Widget _buildListTile() {
    return ListTile(title: _buildTitle(), subtitle: _buildSubtitle());
  }

  Widget _buildDismissBackground({required AlignmentGeometry alignment}) {
    return Container(
      alignment: alignment,
      color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: const Icon(Icons.delete, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Active DB (isUltimo) is never deleted by the controller (regex safety).
    // Disable swipe so the row does not animate away and snap back after a no-op.
    final canDelete = !arquivo.isUltimo;
    return Center(
      child: Dismissible(
        key: Key(arquivo.arquivo.path),
        direction:
            canDelete ? DismissDirection.horizontal : DismissDirection.none,
        background: _buildDismissBackground(alignment: Alignment.centerLeft),
        secondaryBackground: _buildDismissBackground(
          alignment: Alignment.centerRight,
        ),
        onDismissed: canDelete
            ? (_) {
                onDelete(arquivo);
              }
            : null,
        child: Tooltip(
          message: canDelete
              ? 'Deslize para apagar o backup'
              : 'Banco de dados ativo — não pode ser apagado',
          child: Center(child: _buildListTile()),
        ),
      ),
    );
  }
}
