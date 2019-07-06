import 'dart:async';
import 'package:flutter/material.dart';
import './ArquivoWidget.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/ArquivoDeletavelController.dart';

class ArquivosView extends StatefulWidget {
  createState() => ArquivosViewState();
}

class ArquivosViewState extends State<ArquivosView> {
  final chan = new StreamController<
      ArquivoDeletavel>(); // Esse cara recebe os eventos do que tenque apagar, dps ele atualiza os widgets
  List<ArquivoWidget> arquivos = [];

  ArquivosViewState() {
    listen();
  }

  update() async {
    var arq = ArquivoDeletavelController()
        .arquivos
        .map((a) => ArquivoWidget(a, chan))
        .toList();
    this.setState(() => this.arquivos = arq);
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
        body: ListView(children: this.arquivos), // ListView
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.delete),
            onPressed: () =>
                arquivos.forEach((arq) => chan.add(arq.arquivo)) // forEach
            ) // FloatingActionButton
        ); // Scaffold
  }
}
