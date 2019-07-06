import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import '../controller/SnackbarController.dart';
import 'dart:async';

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final StreamController<ArquivoDeletavel> chan;
  ArquivoWidget(this.arquivo, this.chan);

  Widget build(BuildContext ctx) {
    var d = arquivo.data_criacao;
    var texto =
        "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute < 10 ? '0' : ''}${d.minute}";
    var tamanho = "${(this.arquivo.tamanho / 1000000).round()} MB";
    var elemento = ListTile(
        title: Text(texto, style: TextStyle(fontSize: 36) // TextStyle
            ), // Text
        subtitle: Text(tamanho, style: TextStyle(fontSize: 28) // TextStyle
            ) // Text
        ); // ListTile
    return Center(
        child: Dismissible(
            key: Key(this.arquivo.arquivo.path),
            child: Center(child: elemento),
            background: Container(color: Colors.red, child: Icon(Icons.delete)),
            onDismissed: (_) {
              chan.add(this.arquivo);
              SnackbarController(
                      ctx,
                      SnackBar(
                          content:
                              Text("Apagado $texto liberando $tamanho!") // Text
                          ) // SnackBar
                      )
                  .show();
              Future.delayed(Duration(seconds: 3))
                  .then((_) => Scaffold.of(ctx).hideCurrentSnackBar);
            }) // Dismissible
        );
  }
}
