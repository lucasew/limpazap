import 'package:flutter/material.dart';

class SemArquivosWidget extends StatelessWidget {
  const SemArquivosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.done_sharp,
        size: 250,
        color: Colors.green,
        semanticLabel: 'Nenhum backup para limpar',
      ),
    );
  }
}
