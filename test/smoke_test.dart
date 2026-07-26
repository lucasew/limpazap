import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/view/SemArquivosWidget.dart';

void main() {
  testWidgets('empty state shows done icon and large caption', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SemArquivosWidget(),
        ),
      ),
    );

    expect(find.byIcon(Icons.done_sharp), findsOneWidget);
    expect(find.text(SemArquivosWidget.message), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.done_sharp));
    expect(icon.color, Colors.green);
    expect(icon.size, 250);

    final caption = tester.widget<Text>(find.text(SemArquivosWidget.message));
    expect(caption.style?.fontSize, 28);
    expect(caption.style?.color, Colors.green);

    // One accessible name for the empty state (icon/text are decorative).
    expect(find.bySemanticsLabel(SemArquivosWidget.message), findsOneWidget);
  });
}
