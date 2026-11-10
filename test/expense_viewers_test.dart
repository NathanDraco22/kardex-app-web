import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/expense_viewer_page.dart';
import 'package:kardex_business/kardex_business.dart';

void _useSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('la ficha de un gasto operativo no desborda a ${width.toInt()} px', (tester) async {
      _useSurface(tester, Size(width, 1600));

      await tester.pumpWidget(
        MaterialApp(
          home: ExpenseViewerPage(
            expense: _expense(),
            branchName: 'Sucursal Central',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Detalle del Gasto'), findsOneWidget);
      expect(find.text('Gasto Operativo'), findsWidgets);
      expect(find.text('Operativo'), findsOneWidget);
      expect(find.text('Monto del gasto'), findsOneWidget);
      expect(find.textContaining('12,505.00'), findsOneWidget);
      expect(find.text('Servicios básicos'), findsOneWidget);
      expect(find.text('FAC-2026-00124'), findsOneWidget);
      expect(find.text('Vencido'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
    });

    testWidgets('la ficha de un gasto de proveedor no desborda a ${width.toInt()} px', (tester) async {
      _useSurface(tester, Size(width, 1600));

      await tester.pumpWidget(
        MaterialApp(
          home: ExpenseViewerPage(
            expense: _supplierExpense(),
            branchName: 'Sucursal Central',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Gasto de Proveedor'), findsWidgets);
      expect(find.text('Proveedor'), findsWidgets);
      expect(find.text('Distribuidora del Norte'), findsOneWidget);
      expect(find.text('Monto del gasto'), findsOneWidget);
      expect(find.textContaining('3,250.50'), findsOneWidget);
      expect(find.text('Pagado'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
    });
  }

  testWidgets('la ficha muestra Sin descripción cuando el gasto no tiene detalle', (tester) async {
    _useSurface(tester, const Size(768, 1600));

    await tester.pumpWidget(
      MaterialApp(
        home: ExpenseViewerPage(
          expense: _expense(description: null),
          branchName: 'Sucursal Central',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin descripción'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la ficha de un gasto de impuesto muestra su tipo y monto', (tester) async {
    _useSurface(tester, const Size(768, 1600));

    await tester.pumpWidget(
      MaterialApp(
        home: ExpenseViewerPage(
          expense: _taxExpense(),
          branchName: 'Sucursal Central',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Gasto de Impuesto'), findsWidgets);
    expect(find.text('Impuesto'), findsOneWidget);
    expect(find.text('Monto del gasto'), findsOneWidget);
    expect(find.textContaining('987.65'), findsOneWidget);
    expect(find.text('Vencido'), findsNothing);
    expect(find.text('Cerrar'), findsOneWidget);
  });
}

ExpenseInDb _expense({String? description = 'Pago de energía eléctrica de la sucursal central'}) {
  return ExpenseInDb(
    id: 'expense-1',
    createdAt: DateTime(2026, 11, 10, 8),
    branchId: 'branch-1',
    amount: 1250500,
    category: 'Servicios básicos',
    description: description,
    docNumber: 'FAC-2026-00124',
    date: DateTime(2026, 11, 5).millisecondsSinceEpoch,
    dateId: '2026-11-05',
    status: ExpenseStatus.open,
    type: ExpenseType.operative,
    expirationDate: DateTime(2020, 1, 1).millisecondsSinceEpoch,
    createdBy: const UserInfo(id: 'user-1', name: 'María López'),
  );
}

ExpenseInDb _supplierExpense() {
  return ExpenseInDb(
    id: 'expense-2',
    createdAt: DateTime(2026, 10, 20, 9),
    branchId: 'branch-1',
    amount: 325050,
    category: '',
    description: 'Pago de flete y transporte de mercancía.',
    docNumber: 'FACT-2026-00200',
    date: DateTime(2026, 10, 15).millisecondsSinceEpoch,
    dateId: '2026-10-15',
    status: ExpenseStatus.paid,
    type: ExpenseType.supplier,
    expirationDate: DateTime(2026, 11, 15).millisecondsSinceEpoch,
    supplierId: 'supplier-1',
    supplierName: 'Distribuidora del Norte',
    paidAt: DateTime(2026, 10, 18).millisecondsSinceEpoch,
    createdBy: const UserInfo(id: 'user-2', name: 'Carlos Ruiz'),
  );
}

ExpenseInDb _taxExpense() {
  return ExpenseInDb(
    id: 'expense-tax',
    createdAt: DateTime(2026, 11, 2, 10),
    branchId: 'branch-1',
    amount: 98765,
    category: '',
    description: 'Pago de impuesto municipal del período.',
    docNumber: 'IMP-2026-0001',
    date: DateTime(2026, 11, 1).millisecondsSinceEpoch,
    dateId: '2026-11-01',
    status: ExpenseStatus.open,
    type: ExpenseType.tax,
    createdBy: const UserInfo(id: 'user-3', name: 'Ana Torres'),
  );
}
