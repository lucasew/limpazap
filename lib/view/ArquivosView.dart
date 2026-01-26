import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

class ArquivosView extends StatefulWidget {
  createState() => ArquivosViewState();
}


class ArquivosViewState extends State<ArquivosView> {
  final controller = ArquivoDeletavelController();
  Future<List<ArquivoDeletavel>>? arquivosFuture;
  bool inverter = false;
  bool exibirUltimo = false;

  @override
  void initState() {
    super.initState();
    loadArquivos();
  }

  void loadArquivos() {
    controller.inverter = inverter;
    controller.exibirUltimo = exibirUltimo;
    setState(() {
      arquivosFuture = controller.getArquivos();
    });
  }

  Future<void> _onDeleteFile(ArquivoDeletavel file) async {
    await controller.deleteFile(file);
    loadArquivos();
  }

  Future<void> _onDeleteAll() async {
    final arquivos = await arquivosFuture;
    if (arquivos != null && arquivos.isNotEmpty) {
      await controller.deleteFiles(arquivos);
      loadArquivos();
    }
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
            onPressed: loadArquivos,
          ),
          IconButton(
            icon: Icon(inverter ? Icons.fast_forward : Icons.fast_rewind),
            onPressed: () => _toggleState(() => inverter = !inverter),
          ),
          IconButton(
            icon: Icon(exibirUltimo ? Icons.visibility_off : Icons.visibility),
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
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SemArquivosWidget();
          } else {
            final arquivos = snapshot.data!;
            return ArquivosWidget(arquivos, _onDeleteFile);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.delete_sweep),
        onPressed: _onDeleteAll,
      ),
    );
  }
}
