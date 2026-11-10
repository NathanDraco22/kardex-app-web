import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_aggregation.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_period.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_consolidated.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_detail.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_filters.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_header.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_kpi_grid.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('rangeFor', () {
    final now = DateTime(2026, 11, 10, 15, 42, 18);

    test('Hoy devuelve el día actual completo', () {
      final range = rangeFor(ExpenseReportPeriod.today, now: now);

      expect(range.start, DateTime(2026, 11, 10));
      expect(range.end, DateTime(2026, 11, 10));
    });

    test('Ayer devuelve el día anterior', () {
      final range = rangeFor(ExpenseReportPeriod.yesterday, now: now);

      expect(range.start, DateTime(2026, 11, 9));
      expect(range.end, DateTime(2026, 11, 9));
    });

    test('Últimos 7 días incluye hoy y los seis días previos', () {
      final range = rangeFor(ExpenseReportPeriod.last7Days, now: now);

      expect(range.start, DateTime(2026, 11, 4));
      expect(range.end, DateTime(2026, 11, 10));
      expect(range.end.difference(range.start).inDays, 6);
    });

    test('Este mes inicia el día 1 y termina hoy', () {
      final range = rangeFor(ExpenseReportPeriod.thisMonth, now: now);

      expect(range.start, DateTime(2026, 11, 1));
      expect(range.end, DateTime(2026, 11, 10));
    });

    test('Mes anterior cubre el mes completo', () {
      final range = rangeFor(ExpenseReportPeriod.lastMonth, now: now);

      expect(range.start, DateTime(2026, 10, 1));
      expect(range.end, DateTime(2026, 10, 31));
    });

    test('Mes anterior cruza correctamente el cambio de año', () {
      final range = rangeFor(
        ExpenseReportPeriod.lastMonth,
        now: DateTime(2026, 1, 15, 9),
      );

      expect(range.start, DateTime(2025, 12, 1));
      expect(range.end, DateTime(2025, 12, 31));
    });

    test('Personalizado devuelve hoy como rango seguro', () {
      final range = rangeFor(ExpenseReportPeriod.custom, now: now);

      expect(range.start, DateTime(2026, 11, 10));
      expect(range.end, DateTime(2026, 11, 10));
    });
  });

  group('agregación del reporte', () {
    test('consolida operativos por categoría con porcentajes', () {
      final items = [
        _expense(id: 'a1', amount: 6000, category: 'Servicios'),
        _expense(id: 'a2', amount: 1000, category: 'Servicios'),
        _expense(id: 'b1', amount: 3000, category: 'Mantenimiento'),
        _expense(
          id: 's1',
          amount: 2000,
          type: ExpenseType.supplier,
          supplierName: 'Proveedor Uno',
        ),
      ];

      final breakdown = buildExpenseBreakdown(
        items,
        dimension: ExpenseBreakdownDimension.operativeCategory,
      );

      expect(breakdown.total, 10000);
      expect(breakdown.count, 3);
      expect(breakdown.entries, hasLength(2));
      expect(breakdown.entries.first.label, 'Servicios');
      expect(breakdown.entries.first.amount, 7000);
      expect(breakdown.entries.first.count, 2);
      expect(breakdown.entries.first.fraction, closeTo(0.7, 0.0001));
      expect(breakdown.entries.first.percentage, closeTo(70, 0.0001));
      expect(breakdown.entries.last.label, 'Mantenimiento');
      expect(breakdown.entries.last.amount, 3000);
      expect(breakdown.entries.last.fraction, closeTo(0.3, 0.0001));
    });

    test('consolida proveedores y usa un nombre por defecto', () {
      final items = [
        _expense(
          id: 's1',
          amount: 2000,
          type: ExpenseType.supplier,
          supplierName: 'Proveedor Uno',
        ),
        _expense(
          id: 's2',
          amount: 1000,
          type: ExpenseType.supplier,
          supplierName: 'Proveedor Dos',
        ),
        _expense(
          id: 's3',
          amount: 500,
          type: ExpenseType.supplier,
          supplierName: '',
        ),
        _expense(id: 'o1', amount: 9000, category: 'Servicios'),
      ];

      final breakdown = buildExpenseBreakdown(
        items,
        dimension: ExpenseBreakdownDimension.supplier,
      );

      expect(breakdown.total, 3500);
      expect(breakdown.count, 3);
      expect(breakdown.entries.first.label, 'Proveedor Uno');
      expect(breakdown.entries.first.amount, 2000);
      expect(breakdown.entries.first.fraction, closeTo(2000 / 3500, 0.0001));
      expect(
        breakdown.entries.map((entry) => entry.label),
        contains('Proveedor desconocido'),
      );
    });

    test('agrupa top 6 y el resto en Otros sin perder el total', () {
      final items = [
        for (var index = 0; index < 8; index++)
          _expense(
            id: 'expense-$index',
            amount: (8 - index) * 100,
            category: 'Categoría ${index + 1}',
          ),
      ];

      final breakdown = buildExpenseBreakdown(
        items,
        dimension: ExpenseBreakdownDimension.operativeCategory,
      );

      expect(breakdown.total, 3600);
      expect(breakdown.count, 8);
      expect(breakdown.groupCount, 8);
      expect(breakdown.entries, hasLength(7));
      expect(breakdown.entries.last.label, 'Otros');
      expect(breakdown.entries.last.amount, 300);
      expect(breakdown.entries.last.count, 2);
      expect(
        breakdown.entries.fold<double>(0, (sum, entry) => sum + entry.fraction),
        closeTo(1, 0.0001),
      );
    });

    test('suma montos y conteos por tipo ignorando eliminados', () {
      final items = [
        _expense(id: 'o1', amount: 6000),
        _expense(id: 'o2', amount: 4000),
        _expense(
          id: 's1',
          amount: 2500,
          type: ExpenseType.supplier,
          supplierName: 'Proveedor',
        ),
        _expense(id: 't1', amount: 500, type: ExpenseType.tax),
        _expense(id: 'deleted', amount: 9999, isDeleted: true),
      ];

      final totals = summarizeExpenseTypes(items);

      expect(totals.operative, 10000);
      expect(totals.operativeCount, 2);
      expect(totals.supplier, 2500);
      expect(totals.supplierCount, 1);
      expect(totals.tax, 500);
      expect(totals.taxCount, 1);
      expect(totals.total, 13000);
      expect(totals.count, 4);
    });

    test('los impuestos no se mezclan en los consolidados por categoría ni proveedor', () {
      final items = [
        _expense(id: 'op', amount: 1000, category: 'Servicios'),
        _expense(
          id: 'sup',
          amount: 2000,
          type: ExpenseType.supplier,
          supplierName: 'Proveedor Uno',
        ),
        _expense(
          id: 'tax',
          amount: 3000,
          type: ExpenseType.tax,
          category: 'Impuestos locales',
        ),
      ];

      final operative = buildExpenseBreakdown(
        items,
        dimension: ExpenseBreakdownDimension.operativeCategory,
      );
      final supplier = buildExpenseBreakdown(
        items,
        dimension: ExpenseBreakdownDimension.supplier,
      );
      final totals = summarizeExpenseTypes(items);

      expect(operative.total, 1000);
      expect(operative.entries.single.label, 'Servicios');
      expect(supplier.total, 2000);
      expect(supplier.entries.single.label, 'Proveedor Uno');
      expect(totals.tax, 3000);
      expect(totals.taxCount, 1);
    });

    test('una dimensión vacía devuelve un consolidado vacío', () {
      final breakdown = buildExpenseBreakdown(
        const [],
        dimension: ExpenseBreakdownDimension.operativeCategory,
      );

      expect(breakdown.total, 0);
      expect(breakdown.count, 0);
      expect(breakdown.groupCount, 0);
      expect(breakdown.isEmpty, isTrue);
      expect(breakdown.entries, isEmpty);
    });
  });

  group('buildExpensesCsv', () {
    test('usa createdAt, tipo Impuesto y concepto fiscal', () {
      final csv = buildExpensesCsv([
        _expense(
          id: 'tax-category',
          amount: 100000,
          type: ExpenseType.tax,
          category: 'Impuestos locales',
          supplierName: 'No usar',
          createdAt: DateTime(2026, 11, 10, 8),
          date: DateTime(2026, 10, 1).millisecondsSinceEpoch,
        ),
        _expense(
          id: 'tax-description',
          amount: 200000,
          type: ExpenseType.tax,
          category: '',
          description: 'Declaración mensual',
          createdAt: DateTime(2026, 11, 9, 8),
          date: DateTime(2026, 10, 2).millisecondsSinceEpoch,
        ),
      ]);

      expect(csv, contains('Tipo,N° Documento,Concepto,Registro,Estado,Monto'));
      expect(csv, contains('"Impuesto","","Impuestos locales","10-nov-26"'));
      expect(csv, contains('"Impuesto","","Declaración mensual","09-nov-26"'));
      expect(csv, isNot(contains('01-oct-26')));
      expect(csv, isNot(contains('02-oct-26')));
      expect(csv, isNot(contains('No usar')));
    });
  });

  group('ReadExpenseCubit.loadAll', () {
    test('carga todas las páginas hasta agotar hasMore', () async {
      final repository = _PagedExpensesRepository(
        List.generate(5, (index) => _expense(id: 'expense-$index', amount: 100)),
      );
      final cubit = ReadExpenseCubit(
        repository,
        _EmptyExpenseCategoriesRepository(),
        branchId: 'branch-1',
      );
      addTearDown(cubit.close);

      cubit.queryParams = ExpenseQueryParams()..limit = 2;
      await cubit.loadAll(maxPages: 10);

      final state = cubit.state as ReadExpenseSuccess;
      expect(state.items, hasLength(5));
      expect(state.hasMore, isFalse);
      expect(repository.requestedOffsets, [0, 2, 4]);
    });

    test('respeta maxPages y conserva hasMore cuando el período es mayor', () async {
      final repository = _PagedExpensesRepository(
        List.generate(6, (index) => _expense(id: 'expense-$index', amount: 100)),
      );
      final cubit = ReadExpenseCubit(
        repository,
        _EmptyExpenseCategoriesRepository(),
        branchId: 'branch-1',
      );
      addTearDown(cubit.close);

      cubit.queryParams = ExpenseQueryParams()..limit = 2;
      await cubit.loadAll(maxPages: 2);

      final state = cubit.state as ReadExpenseSuccess;
      expect(state.items, hasLength(4));
      expect(state.hasMore, isTrue);
      expect(repository.requestedOffsets, [0, 2]);
    });
  });

  test('el color del consolidado es estable por etiqueta y Otros es neutro', () {
    expect(
      expenseBreakdownColor('Servicios básicos'),
      expenseBreakdownColor('Servicios básicos'),
    );
    expect(
      expenseBreakdownColor('Servicios básicos'),
      isNot(expenseBreakdownColor('Mantenimiento')),
    );
    expect(expenseBreakdownColor('Otros'), AppThemeTokens.neutral);
  });

  group('layout del reporte', () {
    final items = [
      _expense(
        id: 'op-1',
        amount: 7500000,
        category: 'Servicios básicos',
        description: 'Pago de energía eléctrica y agua de la sucursal central.',
        status: ExpenseStatus.paid,
      ),
      _expense(
        id: 'op-2',
        amount: 3200000,
        category: 'Mantenimiento',
        description: 'Reparación del aire acondicionado del área de ventas.',
        expirationDate: DateTime(2026, 11, 1),
      ),
      _expense(
        id: 'sup-1',
        amount: 1850000,
        type: ExpenseType.supplier,
        supplierName: 'Distribuidora del Norte',
        description: 'Flete de mercancía de la semana.',
        status: ExpenseStatus.partiallyPaid,
      ),
      _expense(
        id: 'sup-2',
        amount: 900000,
        type: ExpenseType.supplier,
        supplierName: 'Transportes Rápidos',
        status: ExpenseStatus.draft,
      ),
    ];

    for (final width in [360.0, 900.0, 1280.0]) {
      testWidgets('los componentes del reporte no desbordan a ${width.toInt()} px', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ExpenseReportHeader(branchName: 'Sucursal Central'),
                    const SizedBox(height: 16),
                    ExpenseReportFilters(
                      period: ExpenseReportPeriod.last7Days,
                      range: rangeFor(ExpenseReportPeriod.last7Days),
                      onPeriodSelected: (_) {},
                      onClear: () {},
                      onExport: () {},
                      isRefreshing: false,
                    ),
                    const SizedBox(height: 16),
                    ExpenseReportKpiGrid(items: items),
                    const SizedBox(height: 16),
                    ExpenseReportDetailView(
                      items: items,
                      isDesktop: width >= 900,
                    ),
                    const SizedBox(height: 16),
                    ExpenseReportConsolidatedView(items: items),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Total registrado'), findsOneWidget);
        expect(find.text('Operativos por categoría'), findsOneWidget);
        expect(find.text('Proveedores por proveedor'), findsOneWidget);
      });
    }

    testWidgets('el detalle etiqueta los impuestos y usa categoría o descripción como concepto', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final taxItems = [
        _expense(
          id: 'tax-category',
          amount: 500000,
          type: ExpenseType.tax,
          category: 'Impuestos locales',
          supplierName: 'No debe mostrarse',
        ),
        _expense(
          id: 'tax-description',
          amount: 750000,
          type: ExpenseType.tax,
          category: '',
          description: 'Declaración mensual',
          supplierName: 'Tampoco debe mostrarse',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportDetailView(
                items: taxItems,
                isDesktop: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Impuesto'), findsNWidgets(2));
      expect(find.text('Impuestos locales'), findsOneWidget);
      expect(find.text('Declaración mensual'), findsOneWidget);
      expect(find.textContaining('No debe mostrarse'), findsNothing);
      expect(find.textContaining('Tampoco debe mostrarse'), findsNothing);
    });

    testWidgets('los KPIs muestran Impuestos solo cuando existen gastos fiscales', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportKpiGrid(
                items: [_expense(id: 'operative', amount: 1000)],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Impuestos'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportKpiGrid(
                items: [
                  _expense(id: 'tax', amount: 3000, type: ExpenseType.tax),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Impuestos'), findsOneWidget);
    });

    testWidgets('el detalle pagina localmente de 100 en 100', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final manyItems = [
        for (var index = 0; index < 150; index++)
          _expense(
            id: 'expense-$index',
            amount: 1000 + index,
            docNumber: 'DOC-$index',
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportDetailView(
                items: manyItems,
                isDesktop: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DOC-0'), findsOneWidget);
      expect(find.text('DOC-99'), findsOneWidget);
      expect(find.text('DOC-100'), findsNothing);
      expect(find.text('Mostrar más (50 restantes)'), findsOneWidget);

      final showMore = find.byKey(const ValueKey('expense-report-show-more'));
      await tester.ensureVisible(showMore);
      await tester.pumpAndSettle();
      await tester.tap(showMore);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('DOC-149'), findsOneWidget);
      expect(find.textContaining('Mostrar más'), findsNothing);
    });

    testWidgets('la paginación del detalle vuelve a 100 al cambiar items', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Widget buildDetail(List<ExpenseInDb> items) {
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportDetailView(items: items, isDesktop: true),
            ),
          ),
        );
      }

      final firstItems = [
        for (var index = 0; index < 150; index++)
          _expense(
            id: 'first-$index',
            amount: 1000 + index,
            docNumber: 'FIRST-$index',
          ),
      ];
      final secondItems = [
        for (var index = 0; index < 120; index++)
          _expense(
            id: 'second-$index',
            amount: 2000 + index,
            docNumber: 'SECOND-$index',
          ),
      ];

      await tester.pumpWidget(buildDetail(firstItems));
      await tester.pumpAndSettle();

      final showMore = find.byKey(const ValueKey('expense-report-show-more'));
      await tester.ensureVisible(showMore);
      await tester.pumpAndSettle();
      await tester.tap(showMore);
      await tester.pumpAndSettle();
      expect(find.text('FIRST-149'), findsOneWidget);

      await tester.pumpWidget(buildDetail(secondItems));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('SECOND-99'), findsOneWidget);
      expect(find.text('SECOND-100'), findsNothing);
      expect(find.text('Mostrar más (20 restantes)'), findsOneWidget);
    });

    testWidgets('el KPI Cancelados aparece solo con gastos cancelados', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Widget buildKpi(List<ExpenseInDb> items) {
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportKpiGrid(items: items),
            ),
          ),
        );
      }

      await tester.pumpWidget(
        buildKpi([_expense(id: 'open', amount: 1000)]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancelados'), findsNothing);

      await tester.pumpWidget(
        buildKpi([
          _expense(
            id: 'cancelled',
            amount: 2500,
            status: ExpenseStatus.cancelled,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Cancelados'), findsOneWidget);
      expect(find.text('1 cancelado'), findsOneWidget);
    });

    testWidgets('el consolidado informa los impuestos incluidos en el total', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Widget buildConsolidated(List<ExpenseInDb> items) {
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseReportConsolidatedView(items: items),
            ),
          ),
        );
      }

      await tester.pumpWidget(
        buildConsolidated([_expense(id: 'operative', amount: 1000)]),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Impuestos incluidos en el total'), findsNothing);

      await tester.pumpWidget(
        buildConsolidated([
          _expense(id: 'operative', amount: 1000),
          _expense(id: 'tax', amount: 3000, type: ExpenseType.tax),
        ]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Impuestos incluidos en el total'), findsOneWidget);
      expect(find.textContaining('(1 registro)'), findsOneWidget);
    });
  });
}

ExpenseInDb _expense({
  required String id,
  required int amount,
  ExpenseType type = ExpenseType.operative,
  String category = 'Servicios',
  String supplierName = '',
  String docNumber = '',
  String? description,
  bool isDeleted = false,
  ExpenseStatus status = ExpenseStatus.open,
  DateTime? expirationDate,
  DateTime? createdAt,
  int? date,
}) {
  return ExpenseInDb(
    id: id,
    isDeleted: isDeleted,
    createdAt: createdAt ?? DateTime(2026, 11, 10, 8),
    branchId: 'branch-1',
    amount: amount,
    category: category,
    description: description,
    docNumber: docNumber,
    date: date ?? DateTime(2026, 11, 10).millisecondsSinceEpoch,
    dateId: '2026-11-10',
    status: status,
    type: type,
    supplierName: supplierName,
    expirationDate: expirationDate?.millisecondsSinceEpoch,
    createdBy: const UserInfo(id: 'user-1', name: 'Usuario'),
  );
}

class _PagedExpensesRepository extends ExpensesRepository {
  _PagedExpensesRepository(this.master) : super(ExpensesDataSource());

  final List<ExpenseInDb> master;
  final List<int> requestedOffsets = [];

  @override
  Future<List<ExpenseInDb>> getAllExpenses(ExpenseQueryParams params) async {
    requestedOffsets.add(params.offset);
    return master.skip(params.offset).take(params.limit).toList(growable: false);
  }
}

class _EmptyExpenseCategoriesRepository extends ExpenseCategoriesRepository {
  _EmptyExpenseCategoriesRepository() : super(ExpenseCategoriesDataSource());

  @override
  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async => const [];
}
