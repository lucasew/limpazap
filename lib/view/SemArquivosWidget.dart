import 'package:flutter/material.dart';

/// Empty list body when there are no backups left to clean.
///
/// The app uses large type for low-vision users (see README); the green
/// check alone was not enough, so a matching large caption is shown too.
class SemArquivosWidget extends StatelessWidget {
  const SemArquivosWidget({super.key});

  static const String message = 'Nenhum backup para limpar';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative: announcement comes from the parent [Semantics].
            ExcludeSemantics(
              child: Icon(
                Icons.done_sharp,
                size: 250,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            ExcludeSemantics(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
