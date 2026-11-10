import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/stock_quantity_label.dart';

void main() {
  testWidgets('muestra la unidad de venta y la base', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockQuantityLabel(
            title: "Existencia",
            baseStock: 60,
            baseUnitName: 'Unidad',
            displayUnitName: 'Caja x30',
            displayUnitFactor: 30,
          ),
        ),
      ),
    );

    expect(find.text('Existencia'), findsOneWidget);
    expect(find.text('2 Caja x30'), findsOneWidget);
    expect(find.text('Base: 60 Unidad'), findsOneWidget);
  });

  testWidgets('muestra fracciones de la unidad de venta', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockQuantityLabel(
            baseStock: 15,
            baseUnitName: 'Unidad',
            displayUnitName: 'Caja x30',
            displayUnitFactor: 30,
          ),
        ),
      ),
    );

    expect(find.text('0.5 Caja x30'), findsOneWidget);
    expect(find.text('Base: 15 Unidad'), findsOneWidget);
  });

  testWidgets('sin conversión solo muestra la unidad base', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockQuantityLabel(
            baseStock: 60,
            baseUnitName: 'Libra',
            displayUnitName: 'Libra',
            displayUnitFactor: 1,
          ),
        ),
      ),
    );

    expect(find.text('60 Libra'), findsOneWidget);
    expect(find.textContaining('Base:'), findsNothing);
  });
}
