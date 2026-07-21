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

/// Formats a backup file size for the large-type list row.
///
/// Uses SI decimal units (1000-based) to match the historical `MB` label.
/// Picks B / KB / MB / GB so small files never show as `0 MB` (the old
/// always-round-to-megabytes path did for anything under ~500 KB).
@visibleForTesting
String formatBackupSize(int bytes) {
  if (bytes < 0) {
    bytes = 0;
  }
  if (bytes < 1000) {
    return '$bytes B';
  }
  if (bytes < 1000 * 1000) {
    return '${(bytes / 1000).round()} KB';
  }
  if (bytes < 1000 * 1000 * 1000) {
    return '${(bytes / (1000 * 1000)).round()} MB';
  }
  return '${(bytes / (1000 * 1000 * 1000)).round()} GB';
}

/// Whether a list row may be swipe-deleted.
///
/// Active DB rows ([isUltimo]) are never deletable. Historical backups can be
/// dismissed only when [allowDelete] is true (false while a bulk delete runs).
@visibleForTesting
bool isSwipeDeleteEnabled({
  required bool isUltimo,
  required bool allowDelete,
}) {
  return allowDelete && !isUltimo;
}

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final Function(ArquivoDeletavel) onDelete;

  /// When false, swipe-to-delete is disabled for every row (used while bulk
  /// delete is in flight so a swipe cannot race the sweep).
  final bool allowDelete;

  const ArquivoWidget(
    this.arquivo,
    this.onDelete, {
    this.allowDelete = true,
    super.key,
  });

  String get _textoDataCriacao => formatBackupDateTime(arquivo.dataCriacao);

  String get _textoTamanho => formatBackupSize(arquivo.tamanho);

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

  String get _tooltipMessage {
    if (arquivo.isUltimo) {
      return 'Banco de dados ativo — não pode ser apagado';
    }
    if (!allowDelete) {
      return 'Aguarde o fim da exclusão em lote';
    }
    return 'Deslize para apagar o backup';
  }

  @override
  Widget build(BuildContext context) {
    // Active DB (isUltimo) is never deleted by the controller (regex safety).
    // Also block swipe while the parent disables deletes (bulk sweep in flight)
    // so the row does not animate away and race concurrent deleteFiles.
    final canDelete = isSwipeDeleteEnabled(
      isUltimo: arquivo.isUltimo,
      allowDelete: allowDelete,
    );
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
          message: _tooltipMessage,
          child: Center(child: _buildListTile()),
        ),
      ),
    );
  }
}
