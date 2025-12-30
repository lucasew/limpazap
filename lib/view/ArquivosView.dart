import 'dart:async';
import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';
import './ArquivosWidget.dart';
import './SemArquivosWidget.dart';

class ArquivosView extends StatefulWidget {
  createState() => ArquivosViewState();
}


class ArquivosViewState extends State<ArquivosView> {
  final chan = StreamController<ArquivoDeletavel>();
  Future<List<ArquivoDeletavel>>? arquivosFuture;
  bool inverter = false;
  bool exibirUltimo = false;

  @override
  void initState() {
    super.initState();
    listen();
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

  void update() {
    loadArquivos();
  }

  void listen() {
    chan.stream.listen((ad) async {
      await ad.arquivo.delete();
      update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Limpazap", overflow: TextOverflow.visible),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: update,
          ),
          IconButton(
            icon: Icon(inverter ? Icons.fast_forward : Icons.fast_rewind),
            onPressed: () {
              setState(() {
                inverter = !inverter;
              });
              update();
            },
          ),
          IconButton(
            icon: Icon(exibirUltimo ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                exibirUltimo = !exibirUltimo;
              });
              update();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ArquivoDeletavel>>(
        future: arquivosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SemArquivosWidget();
          } else {
            final arquivos = snapshot.data!;
            return ArquivosWidget(arquivos, chan);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.delete_sweep),
        onPressed: () async {
          final arquivos = await arquivosFuture;
          if (arquivos != null) {
            for (var arq in arquivos) {
              chan.add(arq);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    chan.close();
    super.dispose();
  }
}
