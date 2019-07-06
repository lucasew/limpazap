import 'package:flutter/material.dart';
import '../controller/SnackbarController.dart';

class SemArquivosWidget extends StatelessWidget {
  mostrarInfo(BuildContext ctx) async {
    await Future.delayed(Duration(milliseconds: 500));
    SnackbarController(
            ctx, SnackBar(content: Text("Nenhum arquivo foi encontrado!")))
        .show();
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
