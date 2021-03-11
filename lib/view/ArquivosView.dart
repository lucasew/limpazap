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
  final chan = new StreamController<
      ArquivoDeletavel>(); // Esse cara recebe os eventos do que tenque apagar, dps ele atualiza os widgets
  List<ArquivoDeletavel> arquivos = [];
  bool inverter = false;
  bool exibirUltimo = false;

  ArquivosViewState() {
    listen();
    this.arquivos = updateArquivos();
  }

  List<ArquivoDeletavel> updateArquivos() {
    return ArquivoDeletavelController(
            inverter: this.inverter, exibirUltimo: this.exibirUltimo)
        .arquivos;
  }

  update() async {
    this.setState(() => this.arquivos = updateArquivos());
    // this.setState(() => this.arquivos = []);
  }

  listen() async {
    chan.stream.listen((ad) {
      ad.arquivo.deleteSync();
      update();
    });
  }

  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Limpazap", overflow: TextOverflow.visible),
            backgroundColor: Colors.green,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: update,
                  tooltip: "Atualizar lista"), // IconButton
              IconButton(
                  icon: Icon(this.inverter
                      ? Icons.fast_forward
                      : Icons.fast_rewind), // Icon
                  tooltip: "Inverter/Desinverter ordem",
                  onPressed: () {
                    this.inverter = !this.inverter;
                    update();
                  }), // IconButton
              IconButton(
                  icon: Icon(this.exibirUltimo
                      ? Icons.visibility_off
                      : Icons.visibility),
                  tooltip:
                      "Exibir o ultimo backup feito (não é recomendável apaga-lo!)",
                  onPressed: () {
                    this.exibirUltimo = !this.exibirUltimo;
                    update();
                  })
            ]), // AppBar
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            tooltip: "Apagar tudo!",
            child: Icon(Icons.delete_sweep),
            onPressed: () => arquivos.forEach((arq) => chan.add(arq))),
        body: this.arquivos.length == 0
            ? SemArquivosWidget()
            : ArquivosWidget(this.arquivos, chan) // ArquivosWidget
        ); // Scaffold
  }
}
