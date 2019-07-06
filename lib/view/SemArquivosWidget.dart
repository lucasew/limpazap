import 'package:flutter/material.dart';

class SemArquivosWidget extends StatelessWidget {
  mostrarInfo(BuildContext ctx) async {
    await Future.delayed(Duration(milliseconds: 500));
    Scaffold.of(ctx).showSnackBar(
        SnackBar(content: Text("Nenhum arquivo foi encontrado!")));
    Future.delayed(Duration(seconds: 3), Scaffold.of(ctx).hideCurrentSnackBar);
  }

  Widget build(BuildContext ctx) {
    mostrarInfo(ctx);
    return Center(
        child: Text(
            "Nenhum arquivo encontrado! Toque em atualizar para tentar novamente!",
            style: TextStyle(fontSize: 36),
            textAlign: TextAlign.center));
  }
}
