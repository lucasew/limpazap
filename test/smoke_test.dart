import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/view/SemArquivosWidget.dart';

void main() {
  testWidgets('empty state shows done icon with semantic label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SemArquivosWidget(),
        ),
      ),
    );

    expect(find.byIcon(Icons.done_sharp), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.done_sharp));
    expect(icon.semanticLabel, 'Nenhum backup para limpar');
    expect(icon.color, Colors.green);
    expect(icon.size, 250);
  });
}
