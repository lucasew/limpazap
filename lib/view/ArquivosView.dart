import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

class ArquivosView extends StatefulWidget {
  const ArquivosView({super.key});

  @override
  State<ArquivosView> createState() => ArquivosViewState();
}

class ArquivosViewState extends State<ArquivosView> {
  final _controller = ArquivoDeletavelController();
  Future<List<ArquivoDeletavel>>? arquivosFuture;

  @override
  void initState() {
    super.initState();
    loadArquivos();
  }

  void loadArquivos() {
    setState(() {
      arquivosFuture = _controller.getArquivos();
    });
  }

  void _toggleAndReload(void Function() mutate) {
    mutate();
    loadArquivos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpazap', overflow: TextOverflow.visible),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadArquivos),
          IconButton(
            icon: Icon(
              _controller.inverter ? Icons.fast_forward : Icons.fast_rewind,
            ),
            onPressed: () =>
                _toggleAndReload(() => _controller.inverter = !_controller.inverter),
          ),
          IconButton(
            icon: Icon(
              _controller.exibirUltimo
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => _toggleAndReload(
              () => _controller.exibirUltimo = !_controller.exibirUltimo,
            ),
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
            return const SemArquivosWidget();
          } else {
            final arquivos = snapshot.data!;
            return ArquivosWidget(arquivos, (file) async {
              await _controller.deleteFile(file);
              loadArquivos();
            });
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.delete_sweep),
        onPressed: () async {
          final arquivos = await arquivosFuture;
          if (arquivos != null) {
            await _controller.deleteFiles(arquivos);
            loadArquivos();
          }
        },
      ),
    );
  }
}
