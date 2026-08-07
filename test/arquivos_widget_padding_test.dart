import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpazap/view/ArquivosWidget.dart';

void main() {
  testWidgets('list reserves bottom space so rows clear the parent FAB',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArquivosWidget(const [], (_) {}),
        ),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.padding, const EdgeInsets.only(bottom: 88));
  });
}
