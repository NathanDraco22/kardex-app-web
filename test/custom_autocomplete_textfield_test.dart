import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/super_widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

void main() {
  late TextEditingController controller;
  late List<String> changes;
  late List<String> closed;

  setUp(() {
    controller = TextEditingController();
    changes = <String>[];
    closed = <String>[];
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pumpField(WidgetTester tester, {bool allowFreeText = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomAutocompleteTextfield<String>(
              controller: controller,
              allowFreeText: allowFreeText,
              onChanged: changes.add,
              onClose: closed.add,
              onSearch: (value) async => const ['Libra', 'Litro', 'Metro'],
              suggestionBuilder: (values, close) {
                return ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(values[index]),
                    onTap: () => close(values[index]),
                  ),
                );
              },
              titleBuilder: (value) => value,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder innerField() {
    return find.descendant(
      of: find.byType(SearchFieldDebounced),
      matching: find.byType(TextField),
    );
  }

  Future<void> openPopup(WidgetTester tester) async {
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(SearchFieldDebounced), findsOneWidget);
  }

  Future<void> typeInPopup(WidgetTester tester, String text) async {
    await tester.enterText(innerField(), text);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  Future<void> closePopup(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(SearchFieldDebounced))).pop();
    await tester.pumpAndSettle();
  }

  testWidgets('texto libre escrito en el popup se conserva al cerrar sin seleccionar', (tester) async {
    await pumpField(tester);

    await openPopup(tester);
    await typeInPopup(tester, '1/4 Libra');
    await closePopup(tester);

    expect(controller.text, '1/4 Libra');
    expect(changes, ['1/4 Libra']);
    expect(closed, isEmpty);
  });

  testWidgets('el primer carácter del campo exterior no queda como valor final', (tester) async {
    await pumpField(tester);

    final outerField = find.byType(TextFormField);
    await tester.enterText(outerField, 'C');
    await tester.pumpAndSettle();

    expect(find.byType(SearchFieldDebounced), findsOneWidget);
    expect(changes, isEmpty);

    await typeInPopup(tester, '1/4 Libra');
    await closePopup(tester);

    expect(controller.text, '1/4 Libra');
    expect(changes, ['1/4 Libra']);
  });

  testWidgets('sin allowFreeText el cierre sin selección limpia el texto', (tester) async {
    await pumpField(tester, allowFreeText: false);

    await openPopup(tester);
    await typeInPopup(tester, '1/4 Libra');
    await closePopup(tester);

    expect(controller.text, isEmpty);
    expect(changes, isEmpty);
    expect(closed, isEmpty);
  });

  testWidgets('no restaura el valor previo si el texto libre cambió', (tester) async {
    await pumpField(tester);

    await openPopup(tester);
    await typeInPopup(tester, 'Li');
    await tester.tap(find.text('Libra'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Libra');
    expect(closed, ['Libra']);

    changes.clear();

    await openPopup(tester);
    await typeInPopup(tester, '1/4 Libra');
    await closePopup(tester);

    expect(controller.text, '1/4 Libra');
    expect(changes, ['1/4 Libra']);
    expect(closed, ['Libra']);
  });
}
