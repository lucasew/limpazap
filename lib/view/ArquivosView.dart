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

  ArquivosViewState() {
    listen();
    this.arquivos = update_arquivos();
  }

  List<ArquivoDeletavel> update_arquivos() {
    return ArquivoDeletavelController().arquivos;
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
              FlatButton(
                  child: Icon(Icons.refresh), onPressed: update) // FlatButton
            ]), // AppBar
        floatingActionButton: FloatingActionButton(
            tooltip: "Apagar tudo!",
            child: Icon(Icons.delete),
            onPressed: () => arquivos.forEach((arq) => chan.add(arq))),
        body: this.arquivos.length == 0
            ? SemArquivosWidget()
            : ArquivosWidget(this.arquivos, chan) // ArquivosWidget
        ); // Scaffold
  }
}
