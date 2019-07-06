import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import 'dart:async';

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final StreamController<ArquivoDeletavel> chan;
  ArquivoWidget(this.arquivo, this.chan);

  Widget build(BuildContext ctx) {
    var d = arquivo.data_criacao;
    var texto = "${d.day}/${d.month}/${d.year}";
    var tamanho = "${(this.arquivo.tamanho / 1000000).round()} MB";
    return ButtonBar(children: <Widget>[
      Column(children: <Widget>[
        Row(children: <Widget>[
          Icon(Icons.calendar_today), // Icon
          Text(texto, style: TextStyle(fontSize: 36)) // Text
        ]), // Row
        Row(children: <Widget>[
          Icon(Icons.format_size),
          Text(tamanho, style: TextStyle(fontSize: 36))
        ]) // Row
      ]),
      FlatButton(
          child: Icon(Icons.delete),
          onPressed: () {
            chan.add(this.arquivo);
            Scaffold.of(ctx).showSnackBar(SnackBar(
                    content: Text("Apagado $texto liberando $tamanho!") // Text
                    ) // SnackBar
                ); // showSnackBar
            Future.delayed(Duration(seconds: 3))
                .then((_) => Scaffold.of(ctx).hideCurrentSnackBar);
          }) // FlatButton
    ]);
  }
}
