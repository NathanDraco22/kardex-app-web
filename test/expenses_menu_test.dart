import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_menu_screen.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

void _useSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('el hub de gastos no desborda a ${width.toInt()} px', (tester) async {
      _useSurface(tester, Size(width, 1600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: ExpensesHubBody(
              shortcutBuilder: (_, child) => child,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Centro de Gastos'), findsOneWidget);
      expect(find.text('Operación'), findsOneWidget);
      expect(find.text('Análisis y configuración'), findsOneWidget);
      expect(find.text('Gastos Operativos'), findsOneWidget);
      expect(find.text('Gastos de Proveedores'), findsOneWidget);
      expect(find.text('Categorías de Gastos'), findsOneWidget);
      expect(find.text('Reporte de Gastos'), findsOneWidget);
      expect(find.text('Clasifica tus gastos para mejorar los reportes.'), findsOneWidget);
      expect(find.byType(AppActionTile), findsNWidgets(4));
    });
  }
}
