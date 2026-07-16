import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import '../core/error_handler.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

class ArquivosView extends StatefulWidget {
  const ArquivosView({super.key});

  @override
  createState() => ArquivosViewState();
}

class ArquivosViewState extends State<ArquivosView> {
  Future<List<ArquivoDeletavel>>? arquivosFuture;
  bool inverter = false;
  bool exibirUltimo = false;

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
            onPressed: loadArquivos,
          ),
          IconButton(
            icon: Icon(inverter ? Icons.fast_forward : Icons.fast_rewind),
            tooltip: inverter ? 'Mais antigos primeiro' : 'Mais recentes primeiro',
            onPressed: () => _toggleState(() => inverter = !inverter),
          ),
          IconButton(
            icon: Icon(exibirUltimo ? Icons.visibility_off : Icons.visibility),
            tooltip: exibirUltimo
                ? 'Ocultar banco de dados ativo'
                : 'Exibir banco de dados ativo',
            onPressed: () => _toggleState(() => exibirUltimo = !exibirUltimo),
          ),
        ],
      ),
      body: FutureBuilder<List<ArquivoDeletavel>>(
        future: arquivosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            ErrorHandler.reportError(snapshot.error, snapshot.stackTrace, 'ArquivosView FutureBuilder');
            return const Center(child: Text('Ocorreu um erro ao carregar os arquivos. Tente novamente mais tarde.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SemArquivosWidget();
          } else {
            final arquivos = snapshot.data!;
            return ArquivosWidget(arquivos, (file) async {
              await ArquivoDeletavelController().deleteFile(file);
              loadArquivos();
            });
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        tooltip: 'Apagar todos os backups listados',
        child: const Icon(Icons.delete_sweep),
        onPressed: () async {
          final arquivos = await arquivosFuture;
          if (arquivos != null) {
            await ArquivoDeletavelController().deleteFiles(arquivos);
            loadArquivos();
          }
        },
      ),
    );
  }
}
