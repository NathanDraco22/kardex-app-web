import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/operative_expenses/dialogs/create_expense_dialog.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_form_utils.dart';
import 'package:kardex_app_front/src/modules/expenses/supplier_expenses/dialogs/create_supplier_expense_dialog.dart';
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

  group('parseExpenseAmountCents', () {
    test('acepta separadores anglosajones y locales', () {
      expect(parseExpenseAmountCents('1,234.56'), 123456);
      expect(parseExpenseAmountCents('1.234,56'), 123456);
      expect(parseExpenseAmountCents('12,50'), 1250);
      expect(parseExpenseAmountCents('12.50'), 1250);
    });

    test('acepta miles simples y grupos múltiples con decimal explícito', () {
      expect(parseExpenseAmountCents('1,234'), 123400);
      expect(parseExpenseAmountCents('1.234'), 123400);
      expect(parseExpenseAmountCents('1.234.567,89'), 123456789);
      expect(parseExpenseAmountCents('1,234,567.89'), 123456789);
    });

    test('rechaza formatos malformados, negativos y paréntesis', () {
      for (final value in [
        '1.234.56',
        '1,234,56',
        '1.234,567',
        '1,234,567',
        '1,2345',
        '1.2345',
        '1.234.567',
        '-100',
        '(100)',
        '(-100)',
        '1 234,56',
      ]) {
        expect(parseExpenseAmountCents(value), isNull, reason: value);
      }
    });

    test('rechaza vacío, cero y valores sin dígitos', () {
      expect(parseExpenseAmountCents(''), isNull);
      expect(parseExpenseAmountCents('   '), isNull);
      expect(parseExpenseAmountCents('0'), isNull);
      expect(parseExpenseAmountCents('0.00'), isNull);
      expect(parseExpenseAmountCents('abc'), isNull);
    });

    test('formatea centavos para el valor inicial', () {
      expect(formatExpenseAmountInput(123456), '1,234.56');
      expect(formatExpenseAmountInput(1250), '12.50');
      expect(formatExpenseAmountInput(0), '');
      expect(formatExpenseAmountInput(-1), '');
    });
  });

  group('resolveExpenseStatus', () {
    test('conserva el estado original cuando el crédito no cambió', () {
      for (final status in [
        ExpenseStatus.cancelled,
        ExpenseStatus.partiallyPaid,
        ExpenseStatus.draft,
        ExpenseStatus.paid,
      ]) {
        expect(
          resolveExpenseStatus(
            original: status,
            isCredit: status != ExpenseStatus.paid,
            creditChanged: false,
          ),
          status,
        );
      }
    });

    test('resuelve open/paid cuando el usuario cambia el crédito', () {
      expect(
        resolveExpenseStatus(
          original: ExpenseStatus.open,
          isCredit: false,
          creditChanged: true,
        ),
        ExpenseStatus.paid,
      );
      expect(
        resolveExpenseStatus(
          original: ExpenseStatus.paid,
          isCredit: true,
          creditChanged: true,
        ),
        ExpenseStatus.open,
      );
    });
  });

  group('resolveExpirationDate', () {
    test('conserva el vencimiento original sin cambio de crédito', () {
      expect(
        resolveExpirationDate(
          original: 1000,
          current: 2000,
          isCredit: false,
          creditChanged: false,
        ),
        1000,
      );
    });

    test('limpia el vencimiento al pasar a pagado', () {
      expect(
        resolveExpirationDate(
          original: 1000,
          current: 2000,
          isCredit: false,
          creditChanged: true,
        ),
        isNull,
      );
    });

    test('usa la fecha actual del formulario con crédito activo', () {
      expect(
        resolveExpirationDate(
          original: 1000,
          current: 2000,
          isCredit: true,
          creditChanged: false,
        ),
        2000,
      );
      expect(
        resolveExpirationDate(
          original: 1000,
          current: 3000,
          isCredit: true,
          creditChanged: true,
        ),
        3000,
      );
    });
  });

  test('el payload de edición conserva categoría, estado y vencimiento', () {
    final expense = _supplierExpense(
      category: 'Logística',
      status: ExpenseStatus.partiallyPaid,
      expirationDate: DateTime(2026, 12, 1).millisecondsSinceEpoch,
    );
    final status = resolveExpenseStatus(
      original: expense.status,
      isCredit: true,
      creditChanged: false,
    );
    final expirationDate = resolveExpirationDate(
      original: expense.expirationDate,
      current: expense.expirationDate,
      isCredit: true,
      creditChanged: false,
    );

    final payload = buildExpensePayload(
      type: expense.type,
      branchId: expense.branchId,
      createdBy: expense.createdBy,
      docNumber: expense.docNumber,
      category: expense.category,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
      status: status,
      expirationDate: expirationDate,
      supplierId: expense.supplierId,
      supplierName: expense.supplierName,
    );
    final update = UpdateExpense.fromJson(payload);

    expect(payload['category'], 'Logística');
    expect(payload['dateId'], '2026-10-15');
    expect(update.category, 'Logística');
    expect(update.status, ExpenseStatus.partiallyPaid);
    expect(update.expirationDate, expense.expirationDate);
  });

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('el formulario operativo no desborda a ${width.toInt()} px', (tester) async {
      _useSurface(tester, Size(width, 1600));

      final harness = _FormHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(
        harness.wrap(const CreateExpenseDialog()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nuevo Gasto'), findsOneWidget);
      expect(find.text('Información del gasto'), findsOneWidget);
      expect(find.text('Clasificación y monto'), findsOneWidget);
      expect(find.text('¿Es a crédito?'), findsOneWidget);
      expect(find.text('N° Documento'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
    });

    testWidgets('el formulario de proveedor no desborda a ${width.toInt()} px', (tester) async {
      _useSurface(tester, Size(width, 1600));

      final harness = _FormHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(
        harness.wrap(const CreateSupplierExpenseDialog()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nuevo Gasto'), findsOneWidget);
      expect(find.text('Proveedor'), findsOneWidget);
      expect(find.text('Información del gasto'), findsOneWidget);
      expect(find.text('Monto y detalle'), findsOneWidget);
      expect(find.text('Seleccionar proveedor'), findsOneWidget);
      expect(find.text('¿Es a crédito?'), findsOneWidget);
    });
  }

  testWidgets('el formulario operativo valida categoría y monto', (tester) async {
    _useSurface(tester, const Size(360, 1600));

    final harness = _FormHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.wrap(const CreateExpenseDialog()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('La categoría es requerida'), findsOneWidget);
    expect(find.text('El monto es requerido'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('expense_amount_field')), '0');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un monto mayor a cero'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el campo de monto rechaza valores negativos', (tester) async {
    _useSurface(tester, const Size(360, 1600));

    final harness = _FormHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.wrap(const CreateExpenseDialog()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('expense_amount_field')), '-100');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un monto mayor a cero'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el formulario de proveedor valida proveedor y monto', (tester) async {
    _useSurface(tester, const Size(1280, 1600));

    final harness = _FormHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.wrap(const CreateSupplierExpenseDialog()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Debes seleccionar un proveedor'), findsOneWidget);
    expect(find.text('El monto es requerido'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el número de documento es de solo lectura al editar', (tester) async {
    _useSurface(tester, const Size(1280, 1600));

    final harness = _FormHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(
      harness.wrap(CreateSupplierExpenseDialog(expense: _supplierExpense())),
    );
    await tester.pumpAndSettle();

    final editable = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('supplier_expense_doc_number_field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(editable.readOnly, isTrue);
    expect(find.text('El número de documento no se puede modificar.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FormHarness {
  _FormHarness()
    : writeCubit = WriteExpenseCubit(ExpensesRepository(ExpensesDataSource())),
      categoriesRepository = _FakeExpenseCategoriesRepository();

  final WriteExpenseCubit writeCubit;
  final ExpenseCategoriesRepository categoriesRepository;

  Widget wrap(Widget child) {
    return MaterialApp(
      home: RepositoryProvider<ExpenseCategoriesRepository>.value(
        value: categoriesRepository,
        child: BlocProvider<WriteExpenseCubit>.value(
          value: writeCubit,
          child: child,
        ),
      ),
    );
  }

  void dispose() {
    writeCubit.close();
  }
}

class _FakeExpenseCategoriesRepository extends ExpenseCategoriesRepository {
  _FakeExpenseCategoriesRepository() : super(ExpenseCategoriesDataSource());

  static final List<ExpenseCategoryInDb> _categories = [
    ExpenseCategoryInDb(
      id: 'cat-1',
      createdAt: DateTime(2026, 11, 10),
      name: 'Servicios básicos',
      description: 'Energía, agua e internet.',
      isActive: true,
    ),
  ];

  @override
  List<ExpenseCategoryInDb> get expenseCategories => _categories;

  @override
  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async => _categories;
}

ExpenseInDb _supplierExpense({
  String category = 'Logística',
  ExpenseStatus status = ExpenseStatus.open,
  int? expirationDate,
}) {
  return ExpenseInDb(
    id: 'expense-supplier-1',
    createdAt: DateTime(2026, 10, 20, 9),
    branchId: 'branch-1',
    amount: 325050,
    category: category,
    description: 'Pago de flete y transporte de mercancía.',
    docNumber: 'FACT-2026-00200',
    date: DateTime(2026, 10, 15).millisecondsSinceEpoch,
    dateId: '2026-10-15',
    status: status,
    type: ExpenseType.supplier,
    expirationDate: expirationDate,
    supplierId: 'supplier-1',
    supplierName: 'Distribuidora del Norte',
    createdBy: const UserInfo(id: 'user-2', name: 'Carlos Ruiz'),
  );
}
