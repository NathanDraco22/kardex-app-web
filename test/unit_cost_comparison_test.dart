import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/unit_cost_comparison.dart';

void main() {
  const items = [
    UnitCostItem(label: 'Costo', baseCostInCents: 25),
    UnitCostItem(label: 'Última Compra', baseCostInCents: 30),
  ];

  testWidgets('la tabla muestra la base primero y la unidad seleccionada', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnitCostComparison(
            items: items,
            baseUnitName: '1/4 Libra',
            selectedUnitName: 'Libra',
            selectedUnitFactor: 4,
          ),
        ),
      ),
    );

    expect(find.text('Base'), findsOneWidget);
    expect(find.text('1/4 Libra'), findsOneWidget);
    expect(find.text('Libra'), findsOneWidget);
    expect(find.text('C\$0.25'), findsOneWidget);
    expect(find.text('C\$1.00'), findsOneWidget);
    expect(find.text('C\$0.30'), findsOneWidget);
    expect(find.text('C\$1.20'), findsOneWidget);
  });

  testWidgets('la variante vertical mantiene ambos valores', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnitCostComparison(
            items: items,
            baseUnitName: '1/4 Libra',
            selectedUnitName: 'Libra',
            selectedUnitFactor: 4,
            layout: UnitCostComparisonLayout.vertical,
          ),
        ),
      ),
    );

    expect(find.text('Base · 1/4 Libra'), findsNWidgets(2));
    expect(find.text('C\$0.25'), findsOneWidget);
    expect(find.text('C\$1.00'), findsOneWidget);
    expect(find.text('C\$0.30'), findsOneWidget);
    expect(find.text('C\$1.20'), findsOneWidget);
  });

  testWidgets('no desborda en un ancho angosto', (tester) async {
    const wideItems = [
      UnitCostItem(label: 'Costo', baseCostInCents: 123456),
      UnitCostItem(label: 'Última Compra', baseCostInCents: 654321),
      UnitCostItem(label: 'Costo Máximo', baseCostInCents: 999999),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: UnitCostComparison(
                items: wideItems,
                baseUnitName: '1/4 Libra',
                selectedUnitName: 'Quintal (100 lb)',
                selectedUnitFactor: 400,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('sin unidad extra muestra solo el costo base', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnitCostComparison(
            items: items,
            baseUnitName: '1/4 Libra',
            selectedUnitName: '1/4 Libra',
            selectedUnitFactor: 1,
          ),
        ),
      ),
    );

    expect(find.text('Costo'), findsOneWidget);
    expect(find.text('Última Compra'), findsOneWidget);
    expect(find.text('C\$0.25'), findsOneWidget);
    expect(find.text('C\$0.30'), findsOneWidget);
    expect(find.text('Base'), findsNothing);
  });
}
