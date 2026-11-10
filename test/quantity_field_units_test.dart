import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/quantity_field.dart';
import 'package:kardex_app_front/widgets/elements/quantity_unit_rules.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required int conversionFactor,
    required TextEditingController controller,
    required List<double> changes,
    FocusNode? focusNode,
    bool showButtons = false,
    bool readOnly = false,
    double? max,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            conversionFactor: conversionFactor,
            showButtons: showButtons,
            readOnly: readOnly,
            max: max,
            focusNode: focusNode,
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      ),
    );
  }

  testWidgets('factor 4: 0.3 es inválido y 0.5 es válido', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 4,
      controller: controller,
      changes: changes,
      focusNode: focusNode,
    );

    await tester.tap(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), '0.3');
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();

    expect(find.text('Debe ser múltiplo de 0.25'), findsOneWidget);

    await tester.tap(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), '0.5');
    await tester.pump();
    expect(find.text('Debe ser múltiplo de 0.25'), findsNothing);
    focusNode.unfocus();
    await tester.pump();

    expect(find.text('Debe ser múltiplo de 0.25'), findsNothing);
  });

  testWidgets('factor 30: 30 clics llegan a 1 y el paso 29/30 no se bloquea', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 30,
      controller: controller,
      changes: changes,
      showButtons: true,
      max: 1,
    );

    for (var i = 0; i < 29; i++) {
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
    }

    expect(controller.text, '0.966667');
    final addButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add_circle_outline),
    );
    expect(addButton.onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '1');
    expect(changes.last, 1);
  });

  testWidgets('factor 400 usa paso 0.0025 y rechaza 0.0026', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 400,
      controller: controller,
      changes: changes,
      focusNode: focusNode,
      showButtons: true,
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(controller.text, '0.0025');
    expect(changes.last, closeTo(1 / 400, 1e-12));

    await tester.tap(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), '0.0026');
    await tester.pump();
    focusNode.unfocus();
    await tester.pump();

    expect(find.text('Debe ser múltiplo de 0.0025'), findsOneWidget);
  });

  testWidgets('readOnly ignora las teclas + y -', (tester) async {
    final controller = TextEditingController(text: '1');
    addTearDown(controller.dispose);
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final changes = <double>[];

    await pumpField(
      tester,
      conversionFactor: 4,
      controller: controller,
      changes: changes,
      focusNode: focusNode,
      readOnly: true,
    );

    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(
      LogicalKeyboardKey.equal,
      character: '+',
      physicalKey: PhysicalKeyboardKey.equal,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.numpadSubtract);
    await tester.pump();

    expect(controller.text, '1');
    expect(changes, isEmpty);
  });

  testWidgets('la unidad superior muestra equivalencia en unidad estándar', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            conversionFactor: 400,
            equivalenceUnitName: 'Libra',
            equivalenceFactor: 4,
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('= 100 Libra'), findsOneWidget);
    expect(find.textContaining('1/4'), findsNothing);
  });

  testWidgets('la unidad estándar no muestra equivalencia', (tester) async {
    final controller = TextEditingController(text: '1');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            conversionFactor: 4,
            equivalenceUnitName: 'Libra',
            equivalenceFactor: 4,
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('= '), findsNothing);
  });

  testWidgets('el Form detecta la cantidad fuera de grilla', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: QuantityField(
              conversionFactor: 4,
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '0.3');
    await tester.pump();
    expect(formKey.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextFormField), '0.5');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
  });

  group('QuantityUnitRules', () {
    test('detecta unidades superiores y estándar', () {
      expect(
        QuantityUnitRules.isSuperiorUnit(selectedUnitIndex: 2, defaultUnitIndex: 1),
        isTrue,
      );
      expect(
        QuantityUnitRules.isSuperiorUnit(selectedUnitIndex: 1, defaultUnitIndex: 1),
        isFalse,
      );
      expect(
        QuantityUnitRules.allowsDecimals(selectedUnitIndex: 1, defaultUnitIndex: 1),
        isTrue,
      );
      expect(
        QuantityUnitRules.allowsDecimals(selectedUnitIndex: 2, defaultUnitIndex: 1),
        isFalse,
      );
      expect(
        QuantityUnitRules.allowsDecimals(selectedUnitIndex: 0, defaultUnitIndex: 1),
        isFalse,
      );
    });

    test('conversión exacta 4 -> 1 y 0.5 -> 0 en unidad superior', () {
      // Escala de prueba: Libra factor 4, unidad superior factor 16.
      expect(
        QuantityUnitRules.convertOnUnitChange(
          displayQuantity: 4,
          oldFactor: 4,
          newFactor: 16,
          newUnitIsSuperior: true,
        ),
        1.0,
      );
      expect(
        QuantityUnitRules.convertOnUnitChange(
          displayQuantity: 0.5,
          oldFactor: 4,
          newFactor: 16,
          newUnitIsSuperior: true,
        ),
        isNull,
      );
    });

    test('unidad estándar conserva fracciones y base convierte a entero', () {
      expect(
        QuantityUnitRules.convertOnUnitChange(
          displayQuantity: 0.5,
          oldFactor: 4,
          newFactor: 1,
          newUnitIsSuperior: false,
        ),
        2.0,
      );
      expect(
        QuantityUnitRules.convertOnUnitChange(
          displayQuantity: 0.5,
          oldFactor: 2,
          newFactor: 4,
          newUnitIsSuperior: false,
        ),
        0.25,
      );
    });
  });
}
