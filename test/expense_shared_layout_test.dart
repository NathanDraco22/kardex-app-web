import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_screen.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_filter_panel.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_kpi_strip.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_list_tile.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_page_header.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_table_header.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('los widgets compartidos no desbordan a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final expense = _expense();
      final metrics = ExpenseMetrics.fromExpenses([expense]);
      final searchController = TextEditingController();
      addTearDown(searchController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExpensePageHeader(
                      config: _config,
                      onRefresh: () {},
                      onCreate: () {},
                    ),
                    const SizedBox(height: 16),
                    ExpenseKpiStrip(
                      metrics: metrics,
                      accentColor: _accent,
                      totalLoaded: 1,
                    ),
                    const SizedBox(height: 16),
                    ExpenseFilterPanel(
                      config: _config,
                      searchController: searchController,
                      searchQuery: '',
                      onSearchChanged: (_) {},
                      selectedStatus: ExpenseStatusFilter.all,
                      onStatusChanged: (_) {},
                      selectedCategory: null,
                      onCategoryChanged: (_) {},
                      categories: const [],
                      selectedSupplier: null,
                      onSupplierChanged: (_) {},
                      dateRange: null,
                      onDateRangeChanged: (_) {},
                      hasActiveFilters: false,
                      onClearFilters: () {},
                    ),
                    const SizedBox(height: 16),
                    if (width >= 900) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            const ExpenseTableHeader(conceptLabel: 'Categoría'),
                            ExpenseTableRow(
                              expense: expense,
                              config: _config,
                              isNew: true,
                              isUpdated: false,
                              onTap: () {},
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      ExpenseCardTile(
                        expense: expense,
                        config: _config,
                        isNew: false,
                        isUpdated: true,
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('la pantalla completa no desborda a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final cubit = _FakeReadExpenseCubit([_expense(), _expense(id: 'expense-2')]);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ReadExpenseCubit>.value(
            value: cubit,
            child: const ExpenseListScreen(config: _config),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Gastos')),
        findsOneWidget,
      );
    });
  }

  testWidgets('el estado vacío con filtros locales permite cargar más registros', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = _FakeReadExpenseCubit([_expense()], hasMore: true);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReadExpenseCubit>.value(
          value: cubit,
          child: const ExpenseListScreen(config: _config),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'sin coincidencias');
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Limpiar filtros'), findsWidgets);
    expect(find.text('Cargar más registros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un filtro de servidor sin resultados muestra filtros y carga más', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = _FakeReadExpenseCubit(const [], hasMore: true);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReadExpenseCubit>.value(
          value: cubit,
          child: const ExpenseListScreen(config: _config),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();

    expect(cubit.requestedStatus, isNull);
    expect(cubit.applyFiltersCalls, 1);
    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Limpiar filtros'), findsWidgets);
    expect(find.text('Cargar más registros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pendientes incluye gastos con pago parcial', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = _FakeReadExpenseCubit([
      _expense(id: 'partial', status: ExpenseStatus.partiallyPaid),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReadExpenseCubit>.value(
          value: cubit,
          child: const ExpenseListScreen(config: _config),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();

    expect(cubit.requestedStatus, isNull);
    expect(find.text('Parcial'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loadMore muestra un aviso inline con opción de reintentar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = _FakeReadExpenseCubit(
      [_expense()],
      hasMore: true,
      loadMoreError: 'No se pudieron cargar más gastos.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReadExpenseCubit>.value(
          value: cubit,
          child: const ExpenseListScreen(config: _config),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar más gastos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Cargar más registros'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('loadMore no muta el offset y lo alinea después de eliminar', () async {
    final master = List.generate(6, (index) => _expense(id: 'expense-$index'));
    final repository = _FakeExpensesRepository(master);
    final cubit = ReadExpenseCubit(
      repository,
      _FakeExpenseCategoriesRepository(),
      branchId: 'branch-1',
    );
    addTearDown(cubit.close);

    await cubit.getAll(ExpenseQueryParams()..limit = 2);
    final firstState = cubit.state as ReadExpenseSuccess;
    expect(firstState.items.length, 2);
    expect(_requestedOffset(repository), 0);
    expect(cubit.queryParams.offset, 0);

    cubit.markExpenseDeleted(firstState.items.first);
    await cubit.loadMore();

    expect(_requestedOffset(repository), 1);
    expect(cubit.queryParams.offset, 0, reason: 'loadMore no debe mutar los filtros');

    await cubit.refresh();
    expect(_requestedOffset(repository), 0, reason: 'refresh siempre pide la primera página');
  });

  test('crear un gasto fuera del filtro de servidor no altera el offset', () async {
    final master = List.generate(
      6,
      (index) => _expense(id: 'expense-$index', status: ExpenseStatus.paid),
    );
    final repository = _FakeExpensesRepository(master);
    final cubit = ReadExpenseCubit(
      repository,
      _FakeExpenseCategoriesRepository(),
      branchId: 'branch-1',
    );
    addTearDown(cubit.close);

    await cubit.getAll(
      ExpenseQueryParams()
        ..limit = 2
        ..status = ExpenseStatus.paid.name,
    );

    final openExpense = _expense(id: 'open-new', status: ExpenseStatus.open);
    repository.insertFirst(openExpense);
    cubit.markExpenseCreated(openExpense);
    await cubit.loadMore();
    expect(_requestedOffset(repository), 2);

    final paidExpense = _expense(id: 'paid-new', status: ExpenseStatus.paid);
    repository.insertFirst(paidExpense);
    cubit.markExpenseCreated(paidExpense);
    await cubit.loadMore();
    expect(_requestedOffset(repository), 5);
  });

  test('una eliminación durante loadMore descarta la página y alinea el offset', () async {
    final master = List.generate(6, (index) => _expense(id: 'expense-$index'));
    final repository = _FakeExpensesRepository(master);
    final cubit = ReadExpenseCubit(
      repository,
      _FakeExpenseCategoriesRepository(),
      branchId: 'branch-1',
    );
    addTearDown(cubit.close);

    await cubit.getAll(ExpenseQueryParams()..limit = 2);
    final firstState = cubit.state as ReadExpenseSuccess;

    repository.onRequest = (params) {
      if (params.offset == 2) {
        repository.removeFromMaster('expense-1');
        cubit.markExpenseDeleted(firstState.items[1]);
      }
    };

    await cubit.loadMore();
    repository.onRequest = null;
    final discardedState = cubit.state as ReadExpenseSuccess;
    expect(discardedState.isLoadingMore, isFalse);
    expect(discardedState.loadMoreError, isNull);
    expect(_itemIds(cubit), ['expense-0']);

    await cubit.loadMore();
    expect(_requestedOffset(repository), 1);
    expect(_itemIds(cubit), ['expense-0', 'expense-2', 'expense-3']);
  });

  test('una creación durante loadMore descarta la página y alinea el offset', () async {
    final master = List.generate(6, (index) => _expense(id: 'expense-$index'));
    final repository = _FakeExpensesRepository(master);
    final cubit = ReadExpenseCubit(
      repository,
      _FakeExpenseCategoriesRepository(),
      branchId: 'branch-1',
    );
    addTearDown(cubit.close);

    await cubit.getAll(ExpenseQueryParams()..limit = 2);
    final created = _expense(id: 'expense-new');

    repository.onRequest = (params) {
      if (params.offset == 2) {
        repository.insertFirst(created);
        cubit.markExpenseCreated(created);
      }
    };

    await cubit.loadMore();
    repository.onRequest = null;
    final discardedState = cubit.state as ReadExpenseSuccess;
    expect(discardedState.isLoadingMore, isFalse);
    expect(discardedState.loadMoreError, isNull);
    expect(_itemIds(cubit), ['expense-new', 'expense-0', 'expense-1']);

    await cubit.loadMore();
    expect(_requestedOffset(repository), 3);
    expect(
      _itemIds(cubit),
      ['expense-new', 'expense-0', 'expense-1', 'expense-2', 'expense-3'],
    );
  });

  test('loadMore expone el error y lo limpia al reintentar', () async {
    final master = List.generate(6, (index) => _expense(id: 'expense-$index'));
    final repository = _FakeExpensesRepository(master);
    final cubit = ReadExpenseCubit(
      repository,
      _FakeExpenseCategoriesRepository(),
      branchId: 'branch-1',
    );
    addTearDown(cubit.close);

    await cubit.getAll(ExpenseQueryParams()..limit = 2);
    repository.failOnOffset = 2;

    await cubit.loadMore();
    final failedState = cubit.state as ReadExpenseSuccess;
    expect(failedState.loadMoreError, isNotNull);
    expect(failedState.isLoadingMore, isFalse);

    await cubit.loadMore();
    final retriedState = cubit.state as ReadExpenseSuccess;
    expect(retriedState.loadMoreError, isNull);
    expect(retriedState.items.length, greaterThan(2));
  });

  test('ReadExpenseSearching.copyWith conserva el subtipo', () {
    final searching = ReadExpenseSearching([_expense()]);

    final copied = searching.copyWith(isLoadingMore: true);

    expect(copied, isA<ReadExpenseSearching>());
  });

  testWidgets('la nota KPI compara visibles contra cargados', (tester) async {
    final metrics = ExpenseMetrics.fromExpenses([_expense()]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseKpiStrip(
            metrics: metrics,
            accentColor: _accent,
            totalLoaded: 5,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Montos sobre 1 registros visibles de 5 cargados.'),
      findsOneWidget,
    );
  });

  testWidgets('la nota KPI se oculta sin registros cargados', (tester) async {
    final metrics = ExpenseMetrics.fromExpenses([_expense()]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseKpiStrip(
            metrics: metrics,
            accentColor: _accent,
            totalLoaded: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Montos sobre'), findsNothing);
  });
}

int _requestedOffset(_FakeExpensesRepository repository) {
  return int.parse(repository.requests.last['offset']!);
}

List<String> _itemIds(ReadExpenseCubit cubit) {
  return (cubit.state as ReadExpenseSuccess).items.map((expense) => expense.id).toList();
}

class _FakeExpensesRepository extends ExpensesRepository {
  _FakeExpensesRepository(this.master) : super(ExpensesDataSource());

  final List<ExpenseInDb> master;
  final List<Map<String, String>> requests = [];
  void Function(ExpenseQueryParams params)? onRequest;
  int? failOnOffset;

  @override
  Future<List<ExpenseInDb>> getAllExpenses(ExpenseQueryParams params) async {
    requests.add(params.toMap());
    onRequest?.call(params);
    if (failOnOffset == params.offset) {
      failOnOffset = null;
      throw Exception('Fallo simulado');
    }

    final filtered = master
        .where((expense) {
          if (params.status != null && expense.status.name != params.status) return false;
          if (params.type != null && expense.type.name != params.type) return false;
          if (params.branchId != null && expense.branchId != params.branchId) return false;
          if (params.category != null && expense.category != params.category) return false;
          if (params.supplierId != null && expense.supplierId != params.supplierId) return false;
          return true;
        })
        .toList(growable: false);

    return filtered.skip(params.offset).take(params.limit).toList(growable: false);
  }

  void insertFirst(ExpenseInDb expense) {
    master.insert(0, expense);
  }

  void removeFromMaster(String expenseId) {
    master.removeWhere((expense) => expense.id == expenseId);
  }
}

class _FakeExpenseCategoriesRepository extends ExpenseCategoriesRepository {
  _FakeExpenseCategoriesRepository() : super(ExpenseCategoriesDataSource());

  @override
  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async => const [];
}

class _FakeReadExpenseCubit extends ReadExpenseCubit {
  _FakeReadExpenseCubit(
    List<ExpenseInDb> items, {
    this.hasMore = false,
    this.loadMoreError,
    List<ExpenseInDb>? filteredItems,
  }) : filteredItems = filteredItems ?? items,
       super(
         ExpensesRepository(ExpensesDataSource()),
         ExpenseCategoriesRepository(ExpenseCategoriesDataSource()),
         branchId: 'branch-1',
       ) {
    emit(
      ReadExpenseSuccess(
        items,
        hasMore: hasMore,
        loadMoreError: loadMoreError,
      ),
    );
  }

  final bool hasMore;
  final String? loadMoreError;
  final List<ExpenseInDb> filteredItems;
  String? requestedStatus;
  int applyFiltersCalls = 0;

  @override
  Future<void> applyFilters({
    String? status,
    String? category,
    String? supplierId,
    int? startDate,
    int? endDate,
  }) async {
    requestedStatus = status;
    applyFiltersCalls++;
    emit(
      ReadExpenseSuccess(
        filteredItems,
        hasMore: hasMore,
        loadMoreError: loadMoreError,
      ),
    );
  }
}

const Color _accent = Color(0xFF16A34A);

const ExpenseListConfig _config = ExpenseListConfig(
  title: 'Gastos Operativos',
  subtitle: 'Controla los egresos diarios de caja, servicios y mantenimiento.',
  icon: Icons.account_balance_wallet_rounded,
  accentColor: _accent,
  expenseType: ExpenseType.operative,
  conceptLabel: 'Categoría',
  searchHint: 'Buscar por categoría, documento o descripción...',
  emptyTitle: 'Sin gastos operativos',
  emptySubtitle: 'Registra tu primer egreso operativo.',
  createButtonLabel: 'Nuevo Gasto',
  supportsCategoryFilter: true,
  supportsSupplierFilter: true,
  onCreate: _noopCreate,
  onEdit: _noopEdit,
  onOpenViewer: _noopViewer,
);

Future<ExpenseInDb?> _noopCreate(BuildContext context) async => null;

Future<ExpenseInDb?> _noopEdit(BuildContext context, ExpenseInDb expense) async => null;

Future<void> _noopViewer(BuildContext context, ExpenseInDb expense) async {}

ExpenseInDb _expense({
  String id = 'expense-1',
  ExpenseStatus status = ExpenseStatus.open,
}) {
  return ExpenseInDb(
    id: id,
    createdAt: DateTime(2026, 11, 10, 8),
    branchId: 'branch-1',
    amount: 1250500,
    category: 'Servicios básicos',
    description: 'Pago de energía eléctrica de la sucursal central',
    docNumber: 'FAC-2026-00124',
    date: DateTime(2026, 11, 10).millisecondsSinceEpoch,
    dateId: '2026-11-10',
    status: status,
    type: ExpenseType.operative,
    expirationDate: DateTime(2026, 11, 1).millisecondsSinceEpoch,
    createdBy: const UserInfo(id: 'user-1', name: 'Usuario'),
  );
}
