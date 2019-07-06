import 'dart:async';
import 'package:flutter/material.dart';
import './ArquivoWidget.dart';
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

  ArquivosViewState() {
    listen();
    this.arquivos = update_arquivos();
  }

  List<ArquivoDeletavel> update_arquivos() {
    var arquivos = ArquivoDeletavelController().arquivos;
    arquivos.sort((x, y) => x.data_criacao.compareTo(y.data_criacao));
    if (this.inverter) arquivos = arquivos.reversed.toList();
    return arquivos;
  }

  update() async {
    this.setState(() => this.arquivos = update_arquivos());
  }

  listen() async {
    chan.stream.listen((ad) {
      ad.apagar();
      update();
    });
  }

  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Limpador de WhatsApp"),
            backgroundColor: Colors.green,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: update,
                  tooltip: "Atualizar lista"), // IconButton
              IconButton(
                  icon: Icon(this.inverter
                      ? Icons.fast_rewind
                      : Icons.fast_forward), // Icon
                  tooltip: "Inverter/Desinverter ordem",
                  onPressed: () {
                    this.inverter = !this.inverter;
                    update();
                  }) // IconButton
            ]), // AppBar
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            tooltip: "Apagar tudo!",
            child: Icon(Icons.delete),
            onPressed: () => arquivos.forEach((arq) => chan.add(arq))),
        body: this.arquivos.length == 0
            ? SemArquivosWidget()
            : ArquivosWidget(this.arquivos, chan) // ArquivosWidget
        ); // Scaffold
  }
}
