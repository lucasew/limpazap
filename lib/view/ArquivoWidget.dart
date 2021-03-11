import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/SnackbarController.dart';
import 'dart:async';

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final StreamController<ArquivoDeletavel> chan;
  ArquivoWidget(this.arquivo, this.chan);

  Widget build(BuildContext ctx) {
    var d = arquivo.dataCriacao;
    var texto =
        "${d.day}.${d.month}.${d.year} ${d.hour}:${d.minute < 10 ? '0' : ''}${d.minute}";
    var tamanho = "${(this.arquivo.tamanho / 1000000).round()} MB";
    var elemento = ListTile(
        title: FittedBox(child:
            Row(children: <Widget>[
                Icon(arquivo.isUltimo ? Icons.warning : Icons.history, size: 36),
                Text(
                    texto, 
                    style: TextStyle(fontSize: 36), // TextStyle
                ), // Text
            ]), // Row
        ), // FittedBox
        subtitle: Row(children: <Widget>[
          Icon(Icons.sd_card, size: 36),
          Text(
                  tamanho,
                  style: TextStyle(fontSize: 28), // TextStyle
              ) // Text
        ], ) // Row
        ); // ListTile
    return Center(
        child: Dismissible(
            key: Key(this.arquivo.arquivo.path),
            child: Center(child: elemento),
            background: Container(
                alignment: Alignment.centerLeft,
                color: Colors.red,
                child: Icon(Icons.delete, size: 36), // Icon
                padding: EdgeInsets.symmetric(horizontal: 30)
            ), // Container
            secondaryBackground: Container(
                alignment: Alignment.centerRight, 
                color: Colors.red, 
                child: Icon(Icons.delete,size: 36),
                padding: EdgeInsets.symmetric(horizontal: 30)
            ),
            onDismissed: (_) {
              chan.add(this.arquivo);
            }) // Dismissible
        );
  }
}
