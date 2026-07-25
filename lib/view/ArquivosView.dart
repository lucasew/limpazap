import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import '../core/error_handler.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

/// Drops rows whose swipe-delete already fired [Dismissible.onDismissed].
///
/// Flutter requires the dismissed widget to leave the tree on the next build;
/// keeping the path in [pendingPaths] until reload/filter prevents the
/// "Dismissible still part of the tree" assertion when the parent rebuilds
/// before the async delete + reload finishes.
@visibleForTesting
List<ArquivoDeletavel> withoutPendingDeletes(
  List<ArquivoDeletavel> files,
  Set<String> pendingPaths,
) {
  if (pendingPaths.isEmpty) {
    return files;
  }
  return files
      .where((file) => !pendingPaths.contains(file.arquivo.path))
      .toList(growable: false);
}

class ArquivosView extends StatefulWidget {
  const ArquivosView({super.key});

  @override
  State<ArquivosView> createState() => ArquivosViewState();
}

class ArquivosViewState extends State<ArquivosView> {
  Future<List<ArquivoDeletavel>>? arquivosFuture;
  bool inverter = false;
  bool exibirUltimo = false;

  /// True while bulk delete is in flight — disables the FAB so a second tap
  /// cannot start a parallel sweep of the same list.
  bool _bulkDeleting = false;

  /// Paths removed from the list immediately on swipe so [Dismissible] is not
  /// rebuilt after [Dismissible.onDismissed]. Cleared when reload starts.
  final Set<String> _pendingDeletePaths = <String>{};

  @override
  void initState() {
    super.initState();
    loadArquivos();
  }

  void loadArquivos() {
    setState(() {
      arquivosFuture = ArquivoDeletavelController(
        inverter: inverter,
        exibirUltimo: exibirUltimo,
      ).getArquivos();
    });
  }

  void _toggleState(void Function() stateChange) {
    setState(stateChange);
    loadArquivos();
  }

  Future<void> _deleteOne(ArquivoDeletavel file) async {
    // Same busy flag as the FAB: refuse single-row deletes while a bulk sweep
    // is in flight (avoids concurrent delete + reload).
    if (_bulkDeleting) return;

    final path = file.arquivo.path;
    // Hide the row before the async gap so a rebuild cannot resurrect a
    // dismissed Dismissible with the same key.
    setState(() => _pendingDeletePaths.add(path));
    await ArquivoDeletavelController().deleteFile(file);
    if (!mounted) return;
    // Drop the marker before assigning a new future so a failed delete can
    // show the file again once the reload finishes.
    _pendingDeletePaths.remove(path);
    loadArquivos();
  }

  Future<void> _bulkDelete() async {
    if (_bulkDeleting) return;
    setState(() => _bulkDeleting = true);
    try {
      final arquivos = await arquivosFuture;
      if (!mounted) return;
      if (arquivos == null) return;
      // Match deleteFile safety: only historical backups (never isUltimo).
      // Also skip rows already being deleted via swipe.
      final backups = withoutPendingDeletes(arquivos, _pendingDeletePaths)
          .where((arquivo) => !arquivo.isUltimo)
          .toList();
      if (backups.isEmpty) return;
      await ArquivoDeletavelController().deleteFiles(backups);
      if (!mounted) return;
      _pendingDeletePaths.clear();
      loadArquivos();
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        e,
        stackTrace,
        'ArquivosView bulk delete',
      );
    } finally {
      if (mounted) {
        setState(() => _bulkDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpazap', overflow: TextOverflow.visible),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _bulkDeleting ? null : loadArquivos,
          ),
          IconButton(
            icon: Icon(inverter ? Icons.fast_forward : Icons.fast_rewind),
            tooltip:
                inverter ? 'Mais antigos primeiro' : 'Mais recentes primeiro',
            onPressed: _bulkDeleting
                ? null
                : () => _toggleState(() => inverter = !inverter),
          ),
          IconButton(
            icon: Icon(exibirUltimo ? Icons.visibility_off : Icons.visibility),
            tooltip: exibirUltimo
                ? 'Ocultar banco de dados ativo'
                : 'Exibir banco de dados ativo',
            onPressed: _bulkDeleting
                ? null
                : () => _toggleState(() => exibirUltimo = !exibirUltimo),
          ),
        ],
      ),
      body: FutureBuilder<List<ArquivoDeletavel>>(
        future: arquivosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            ErrorHandler.reportError(snapshot.error, snapshot.stackTrace,
                'ArquivosView FutureBuilder');
            return const Center(
                child: Text(
                    'Ocorreu um erro ao carregar os arquivos. Tente novamente mais tarde.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SemArquivosWidget();
          } else {
            final arquivos =
                withoutPendingDeletes(snapshot.data!, _pendingDeletePaths);
            if (arquivos.isEmpty) {
              return const SemArquivosWidget();
            }
            return ArquivosWidget(
              arquivos,
              _deleteOne,
              // Disable swipe UI for the whole list during bulk delete so a
              // Dismissible cannot animate away mid-sweep.
              allowDelete: !_bulkDeleting,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        tooltip: _bulkDeleting
            ? 'Apagando backups…'
            : 'Apagar todos os backups listados',
        onPressed: _bulkDeleting ? null : _bulkDelete,
        child: _bulkDeleting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.delete_sweep),
      ),
    );
  }
}
