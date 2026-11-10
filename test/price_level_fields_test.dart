import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/price_level_fields.dart';
import 'package:kardex_app_front/widgets/elements/price_level_sync_controller.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  testWidgets('muestra campos base y extra y sincroniza al editar', (tester) async {
    final controller = PriceLevelSyncController(
      levelCount: 2,
      initialPrices: [1000, 2000],
      extraUnits: const [
        ExtraUnit(name: 'Caja', conversionFactor: 12),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PriceLevelsSection(
              controller: controller,
              onChanged: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('price1')), findsOneWidget);
    expect(find.byKey(const Key('price1_extra')), findsOneWidget);
    expect(find.text('Precio Venta 1 (C\$)'), findsOneWidget);
    expect(find.text('Precio Venta 2 (C\$)'), findsOneWidget);
    expect(find.text('Por Caja (C\$):'), findsNWidgets(2));
    expect(controller.extraControllers[0].text, '120.00');

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('price1')),
        matching: find.byType(EditableText),
      ),
      '15.00',
    );
    await tester.pump();

    expect(controller.prices[0], 1500);
    expect(controller.extraControllers[0].text, '180.00');

    controller.dispose();
  });

  testWidgets('sin unidad extra muestra solo el campo base', (tester) async {
    final controller = PriceLevelSyncController(
      levelCount: 4,
      initialPrices: [1000, 0, 0, 0],
      extraUnits: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PriceLevelsSection(
              controller: controller,
              onChanged: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('price1')), findsOneWidget);
    expect(find.byKey(const Key('price4')), findsOneWidget);
    expect(find.text('Precio Venta 1 (C\$)'), findsOneWidget);
    expect(find.text('Precio Venta 4 (C\$)'), findsOneWidget);
    expect(find.byKey(const Key('price1_extra')), findsNothing);

    controller.dispose();
  });
}
