import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/quantity_field.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required int conversionFactor,
    required TextEditingController controller,
    required List<double> changes,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            conversionFactor: conversionFactor,
            showButtons: true,
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      ),
    );
  }

  testWidgets('factor 4 incrementa 0.25 por toque', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 4,
      controller: controller,
      changes: changes,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.25');
    expect(changes.last, 0.25);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.5');
    expect(changes.last, 0.5);
  });

  testWidgets('factor 2 incrementa 0.5 por toque', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 2,
      controller: controller,
      changes: changes,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.5');
    expect(changes.last, 0.5);
  });

  testWidgets('factor 400 conserva el paso 0.0025 con cuatro decimales', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 400,
      controller: controller,
      changes: changes,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.0025');
    expect(changes.last, closeTo(1 / 400, 1e-12));
  });

  testWidgets('factor 30 conserva el paso 1/30 con seis decimales', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 30,
      controller: controller,
      changes: changes,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.033333');
    expect(changes.last, closeTo(1 / 30, 1e-12));
  });

  testWidgets('deshabilita incrementar al alcanzar el máximo', (tester) async {
    final controller = TextEditingController(text: '0.75');
    addTearDown(controller.dispose);
    final changes = <double>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            conversionFactor: 4,
            showButtons: true,
            max: 1,
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '1');
    expect(changes.last, 1);

    final addButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add_circle_outline),
    );
    expect(addButton.onPressed, isNull);
  });

  testWidgets('las teclas + y - funcionan con el campo enfocado', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 4,
      controller: controller,
      changes: changes,
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    await tester.sendKeyEvent(
      LogicalKeyboardKey.equal,
      character: '+',
      physicalKey: PhysicalKeyboardKey.equal,
    );
    await tester.pump();

    expect(controller.text, '0.25');
    expect(changes.last, 0.25);

    await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
    await tester.pump();

    expect(controller.text, '0.5');
    expect(changes.last, 0.5);

    await tester.sendKeyEvent(LogicalKeyboardKey.numpadSubtract);
    await tester.pump();

    expect(controller.text, '0.25');
    expect(changes.last, 0.25);
  });
}
