import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/unit_displayer.dart';

void main() {
  testWidgets('no muestra el factor crudo de la unidad', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnitDisplayer(
            unitName: 'Quintal (100 lb)',
            conversionFactor: 400,
          ),
        ),
      ),
    );

    expect(find.text('Quintal (100 lb)'), findsOneWidget);
    expect(find.text('Quintal (100 lb) (400)'), findsNothing);
  });
}
