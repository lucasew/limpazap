import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import '../core/error_handler.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

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

  Future<void> _bulkDelete() async {
    if (_bulkDeleting) return;
    setState(() => _bulkDeleting = true);
    try {
      final arquivos = await arquivosFuture;
      if (!mounted) return;
      if (arquivos == null) return;
      // Match deleteFile safety: only historical backups (never isUltimo).
      final backups = arquivos.where((arquivo) => !arquivo.isUltimo).toList();
      if (backups.isEmpty) return;
      await ArquivoDeletavelController().deleteFiles(backups);
      if (!mounted) return;
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
            final arquivos = snapshot.data!;
            return ArquivosWidget(
              arquivos,
              (file) async {
                // Same busy flag as the FAB: refuse single-row deletes while a
                // bulk sweep is in flight (avoids concurrent delete + reload).
                if (_bulkDeleting) return;
                await ArquivoDeletavelController().deleteFile(file);
                // Deletion is async; the user may have left this route.
                if (!mounted) return;
                loadArquivos();
              },
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
