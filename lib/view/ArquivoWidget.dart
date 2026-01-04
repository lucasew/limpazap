import 'package:flutter/material.dart';
import '../model/ArquivoDeletavelModel.dart';
import 'dart:async';

class ArquivoWidget extends StatelessWidget {
  final ArquivoDeletavel arquivo;
  final StreamController<ArquivoDeletavel> chan;
  ArquivoWidget(this.arquivo, this.chan);

  String get _textoDataCriacao {
    var d = arquivo.dataCriacao;
    return "${d.day}.${d.month}.${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }

  String get _textoTamanho {
    return "${(arquivo.tamanho / 1000000).round()} MB";
  }

  Widget _buildTitle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 50),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Icon(arquivo.isUltimo ? Icons.warning : Icons.history, size: 36),
            Text(
              _textoDataCriacao,
              style: const TextStyle(fontSize: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: <Widget>[
        const Icon(Icons.sd_card, size: 36),
        Text(
          _textoTamanho,
          style: const TextStyle(fontSize: 28),
        ),
      ],
    );
  }

  Widget _buildListTile() {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
    );
  }

  Widget _buildBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.red,
      child: const Icon(Icons.delete, size: 36),
      padding: const EdgeInsets.symmetric(horizontal: 30),
    );
  }

  Widget _buildSecondaryBackground() {
    return Container(
      alignment: Alignment.centerRight,
      color: Colors.red,
      child: const Icon(Icons.delete, size: 36),
      padding: const EdgeInsets.symmetric(horizontal: 30),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Center(
      child: Dismissible(
        key: Key(arquivo.arquivo.path),
        child: Center(child: _buildListTile()),
        background: _buildBackground(),
        secondaryBackground: _buildSecondaryBackground(),
        onDismissed: (_) {
          chan.add(arquivo);
        },
      ),
    );
  }
}
