import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/read_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/write_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/dialogs/create_expense_category_dialog.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/view/expense_categories_view.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_categories_grid.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_category_card.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  test('el color de una categoría es estable según su nombre', () {
    expect(
      expenseCategoryAccent('Servicios básicos'),
      expenseCategoryAccent('Servicios básicos'),
    );
    expect(
      expenseCategoryAccent('Servicios básicos'),
      isNot(expenseCategoryAccent('Mantenimiento')),
    );
  });

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('el grid de categorías no desborda a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseCategoriesGrid(
                categories: _categories,
                newIds: const {'cat-3'},
                updatedIds: const {'cat-4'},
                onEdit: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Servicios básicos'), findsOneWidget);
      expect(find.text('Mantenimiento y reparaciones'), findsOneWidget);
      expect(find.text('Inactiva'), findsOneWidget);
      expect(find.text('Nueva'), findsOneWidget);
      expect(find.text('Actualizada'), findsOneWidget);
    });

    testWidgets('el estado vacío no desborda a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCategoriesEmptyState(
              hasSearch: false,
              query: '',
              onCreate: () {},
              onClearSearch: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Sin categorías de gastos'), findsOneWidget);
      expect(find.text('Nueva Categoría'), findsOneWidget);
    });

    testWidgets('la búsqueda sin resultados no desborda a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCategoriesEmptyState(
              hasSearch: true,
              query: 'combustible',
              onCreate: () {},
              onClearSearch: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Sin resultados para "combustible"'), findsOneWidget);
      expect(find.text('Limpiar búsqueda'), findsOneWidget);
    });
  }

  testWidgets('una tarjeta inactiva y nueva no desborda a 360 px', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ExpenseCategoriesGrid(
              categories: [
                _category(
                  id: 'cat-new-inactive',
                  name: 'Categoría nueva inactiva',
                  description: 'Descripción de la categoría recién creada.',
                  isActive: false,
                ),
              ],
              newIds: const {'cat-new-inactive'},
              onEdit: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Inactiva'), findsOneWidget);
    expect(find.text('Nueva'), findsOneWidget);
  });

  for (final width in [360.0, 1280.0]) {
    testWidgets('el diálogo de categoría no desborda a ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final writeCubit = WriteExpenseCategoryCubit(_FakeExpenseCategoriesRepository());
      addTearDown(writeCubit.close);
      final isCompact = width < 700;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: writeCubit,
            child: isCompact
                ? const Dialog.fullscreen(
                    child: CreateExpenseCategoryDialog(isFullScreen: true),
                  )
                : Dialog(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const CreateExpenseCategoryDialog(),
                    ),
                  ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nueva Categoría'), findsOneWidget);
      expect(find.text('Nombre *'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
    });
  }

  test('refresh falla, conserva los ítems y expone refreshError', () async {
    final repository = _TestExpenseCategoriesRepository([
      _category(
        id: 'cat-refresh',
        name: 'Servicios básicos',
        description: 'Energía y agua.',
      ),
    ]);
    final cubit = ReadExpenseCategoryCubit(repository);
    addTearDown(cubit.close);

    await cubit.getAll();
    expect(cubit.state, isA<ReadExpenseCategorySuccess>());
    expect((cubit.state as ReadExpenseCategorySuccess).items, hasLength(1));

    repository.fail = true;
    await cubit.refresh();

    final state = cubit.state as ReadExpenseCategorySuccess;
    expect(state.items, hasLength(1));
    expect(state.items.single.name, 'Servicios básicos');
    expect(state.refreshError, isNotNull);
  });

  testWidgets('un refresh fallido mantiene el grid y muestra Reintentar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _TestExpenseCategoriesRepository([
      _category(
        id: 'cat-refresh',
        name: 'Servicios básicos',
        description: 'Energía y agua.',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<ExpenseCategoriesRepository>.value(
          value: repository,
          child: const ExpenseCategoriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Servicios básicos'), findsOneWidget);

    repository.fail = true;
    await tester.tap(find.byTooltip('Actualizar categorías'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Servicios básicos'), findsOneWidget);
    expect(
      find.text('No se pudieron actualizar las categorías. Se muestran los datos anteriores.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('la búsqueda filtra por nombre y descripción y permite limpiar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _TestExpenseCategoriesRepository([
      _category(
        id: 'cat-search-name',
        name: 'Servicios básicos',
        description: 'Energía y agua.',
      ),
      _category(
        id: 'cat-search-description',
        name: 'Logística',
        description: 'Fletes y combustible de transporte.',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<ExpenseCategoriesRepository>.value(
          value: repository,
          child: const ExpenseCategoriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'servicios');
    await tester.pumpAndSettle();
    expect(find.text('Servicios básicos'), findsOneWidget);
    expect(find.text('Logística'), findsNothing);

    await tester.enterText(searchField, 'combustible');
    await tester.pumpAndSettle();
    expect(find.text('Logística'), findsOneWidget);
    expect(find.text('Servicios básicos'), findsNothing);

    await tester.enterText(searchField, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Sin resultados para "zzz"'), findsOneWidget);
    expect(find.text('Limpiar búsqueda'), findsOneWidget);

    await tester.tap(find.text('Limpiar búsqueda'));
    await tester.pumpAndSettle();
    expect(find.text('Servicios básicos'), findsOneWidget);
    expect(find.text('Logística'), findsOneWidget);
  });
}

class _FakeExpenseCategoriesRepository extends ExpenseCategoriesRepository {
  _FakeExpenseCategoriesRepository() : super(ExpenseCategoriesDataSource());

  @override
  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async => const [];
}

class _TestExpenseCategoriesRepository extends ExpenseCategoriesRepository {
  _TestExpenseCategoriesRepository(this.categories) : super(ExpenseCategoriesDataSource());

  final List<ExpenseCategoryInDb> categories;
  bool fail = false;

  @override
  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async {
    if (fail) throw Exception('Fallo simulado');
    return categories;
  }
}

final List<ExpenseCategoryInDb> _categories = [
  _category(
    id: 'cat-1',
    name: 'Servicios básicos',
    description: 'Energía eléctrica, agua, internet y telefonía de la sucursal.',
  ),
  _category(
    id: 'cat-2',
    name: 'Mantenimiento y reparaciones',
    description: 'Reparaciones locativas y mantenimiento preventivo.',
  ),
  _category(
    id: 'cat-3',
    name: 'Nómina',
    description: 'Pagos de salarios y prestaciones del personal operativo.',
    isActive: false,
  ),
  _category(
    id: 'cat-4',
    name: 'Logística',
    description: 'Fletes, combustible y transporte de mercancía.',
  ),
  _category(
    id: 'cat-5',
    name: 'Categoría con un nombre bastante largo para validar el truncado',
    description: null,
  ),
];

ExpenseCategoryInDb _category({
  required String id,
  required String name,
  required String? description,
  bool isActive = true,
}) {
  return ExpenseCategoryInDb(
    id: id,
    createdAt: DateTime(2026, 11, 10, 8),
    name: name,
    description: description,
    isActive: isActive,
  );
}
