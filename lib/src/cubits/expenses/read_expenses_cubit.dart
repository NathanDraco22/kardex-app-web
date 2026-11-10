import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_expenses_state.dart';

class ReadExpenseCubit extends Cubit<ReadExpenseState> {
  ReadExpenseCubit(
    this.expensesRepository,
    this.expenseCategoriesRepository, {
    this.branchId,
  }) : super(ReadExpenseInitial());

  final ExpensesRepository expensesRepository;
  final ExpenseCategoriesRepository expenseCategoriesRepository;

  /// Sucursal usada en las peticiones. En producción se resuelve desde
  /// [AuthCubit]; los tests pueden inyectarla para evitar dependencias globales.
  final String? branchId;

  List<ExpenseCategoryInDb> get expenseCategories => expenseCategoriesRepository.expenseCategories;

  ExpenseQueryParams queryParams = ExpenseQueryParams();

  /// Identificador de la última petición de primera página. Cada [getAll]
  /// incrementa el contador para que las respuestas anteriores se descarten.
  int _requestGeneration = 0;

  /// IDs que el servidor incluiría en la consulta actual. Su longitud es el
  /// offset de la siguiente página; no se mantiene un contador paralelo para
  /// evitar desincronizaciones.
  ///
  /// Invariante: contiene exactamente los registros cargados que cumplen los
  /// filtros enviados al servidor. Las altas que cumplen los filtros se
  /// agregan, las bajas se quitan y las actualizaciones ajustan la membresía
  /// si el registro entra o sale del conjunto filtrado.
  Set<String> _serverCountedIds = <String>{};

  /// Cambia con cada mutación local. Si una página de [loadMore] termina con
  /// una generación distinta a la capturada, sus resultados se descartan
  /// porque el offset pudo quedar desactualizado.
  int _mutationGeneration = 0;

  Future<void> getAll([ExpenseQueryParams? params]) async {
    final generation = ++_requestGeneration;
    queryParams = params ?? ExpenseQueryParams();
    queryParams.branchId = branchId ?? getIt.get<AuthCubit>().currentBranchId;
    final requestedLimit = queryParams.limit;

    if (state is ReadExpenseSuccess) {
      final scopeState = state as ReadExpenseSuccess;
      emit(
        ReadExpenseSearching(
          scopeState.items,
          newItems: scopeState.newItems,
          updatedItems: scopeState.updatedItems,
          deletedItems: scopeState.deletedItems,
          hasMore: false,
          totalLoaded: scopeState.totalLoaded,
        ),
      );
    } else {
      emit(ReadExpenseLoading());
    }

    try {
      final results = await Future.wait([
        expensesRepository.getAllExpenses(queryParams),
        expenseCategoriesRepository.getAllExpenseCategories(),
      ]);
      if (generation != _requestGeneration || isClosed) return;

      final expenses = results[0] as List<ExpenseInDb>;
      _serverCountedIds = expenses.map((expense) => expense.id).toSet();
      emit(
        ReadExpenseSuccess(
          expenses,
          hasMore: expenses.length >= requestedLimit,
        ),
      );
    } catch (error) {
      if (generation != _requestGeneration || isClosed) return;
      emit(ReadExpenseError(error.toString()));
    }
  }

  /// Recarga manteniendo los filtros activos, siempre desde la primera página.
  Future<void> refresh() => getAll(_copyQueryParams(queryParams)..offset = 0);

  /// Aplica filtros de servidor conservando el tipo de gasto y la paginación.
  Future<void> applyFilters({
    String? status,
    String? category,
    String? supplierId,
    int? startDate,
    int? endDate,
  }) {
    final params = _copyQueryParams(queryParams)
      ..status = status
      ..category = category
      ..supplierId = supplierId
      ..startDate = startDate
      ..endDate = endDate
      ..offset = 0;

    return getAll(params);
  }

  Future<void> clearFilters() => applyFilters();

  /// Carga la siguiente página sin vaciar la lista visible.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ReadExpenseSuccess) return;
    if (currentState is ReadExpenseSearching) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    final generation = _requestGeneration;
    final mutationGeneration = _mutationGeneration;
    final pageSize = queryParams.limit;
    final offset = _serverCountedIds.length;
    final params = _copyQueryParams(queryParams)
      ..offset = offset
      ..limit = pageSize;

    emit(currentState.copyWith(isLoadingMore: true, loadMoreError: null));

    try {
      final results = await expensesRepository.getAllExpenses(params);
      if (isClosed) return;
      if (generation != _requestGeneration) return;
      if (mutationGeneration != _mutationGeneration) {
        _finishInvalidatedLoadMore();
        return;
      }

      final latestState = state;
      if (latestState is! ReadExpenseSuccess) return;

      final existingIds = latestState.items.map((expense) => expense.id).toSet();
      final uniqueResults = results.where((expense) => !existingIds.contains(expense.id)).toList();
      final items = [...latestState.items, ...uniqueResults];

      _serverCountedIds.addAll(results.map((expense) => expense.id));
      emit(
        latestState.copyWith(
          items: items,
          isLoadingMore: false,
          hasMore: results.length >= pageSize,
          totalLoaded: items.length,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      if (generation != _requestGeneration) return;
      if (mutationGeneration != _mutationGeneration) {
        _finishInvalidatedLoadMore();
        return;
      }

      final latestState = state;
      if (latestState is ReadExpenseSuccess) {
        emit(
          latestState.copyWith(
            isLoadingMore: false,
            loadMoreError: 'No se pudieron cargar más gastos. Intenta de nuevo.',
          ),
        );
      }
    }
  }

  /// Cierra la carga adicional invalidada por una mutación local sin aplicar
  /// la página recibida. El set de IDs ya refleja la mutación, así que el
  /// siguiente [loadMore] calculará el offset correcto desde cero.
  void _finishInvalidatedLoadMore() {
    final latestState = state;
    if (latestState is ReadExpenseSuccess && latestState.isLoadingMore) {
      emit(latestState.copyWith(isLoadingMore: false, loadMoreError: null));
    }
  }

  Future<void> getById(String expenseId) async {
    emit(ReadExpenseLoading());
    try {
      final expense = await expensesRepository.getExpenseById(expenseId);
      if (expense != null) {
        _serverCountedIds = {expense.id};
        emit(ReadExpenseSuccess([expense]));
      }
    } catch (error) {
      emit(ReadExpenseError(error.toString()));
    }
  }

  void markExpenseCreated(ExpenseInDb item) {
    final currentState = state;
    if (currentState is! ReadExpenseSuccess) return;

    _mutationGeneration++;
    if (_matchesServerFilters(item)) {
      _serverCountedIds.add(item.id);
    }

    final items = [item, ...currentState.items.where((expense) => expense.id != item.id)];
    final newItems = [...currentState.newItems.where((expense) => expense.id != item.id), item];

    emit(
      currentState.copyWith(
        items: items,
        newItems: newItems,
        totalLoaded: items.length,
      ),
    );
  }

  void markExpenseUpdated(ExpenseInDb item) {
    final currentState = state;
    if (currentState is! ReadExpenseSuccess) return;

    _mutationGeneration++;
    if (_matchesServerFilters(item)) {
      _serverCountedIds.add(item.id);
    } else {
      _serverCountedIds.remove(item.id);
    }
    // Aproximación: un cambio de estado/categoría puede alterar el orden del
    // backend, pero la membresía del set se mantiene alineada con los filtros.

    final items = currentState.items.map((expense) => expense.id == item.id ? item : expense).toList();
    final updatedItems = [...currentState.updatedItems.where((expense) => expense.id != item.id), item];

    emit(
      currentState.copyWith(
        items: items,
        updatedItems: updatedItems,
        totalLoaded: items.length,
      ),
    );
  }

  void markExpenseDeleted(ExpenseInDb item) {
    final currentState = state;
    if (currentState is! ReadExpenseSuccess) return;

    _mutationGeneration++;
    _serverCountedIds.remove(item.id);

    final items = currentState.items.where((expense) => expense.id != item.id).toList();
    final deletedItems = [...currentState.deletedItems.where((expense) => expense.id != item.id), item];

    emit(
      currentState.copyWith(
        items: items,
        deletedItems: deletedItems,
        totalLoaded: items.length,
      ),
    );
  }

  /// Evalúa los filtros que se envían al servidor para saber si un cambio
  /// local debe alterar el offset de la siguiente página.
  bool _matchesServerFilters(ExpenseInDb item) {
    final params = queryParams;
    if (params.type != null && item.type.name != params.type) return false;
    if (params.status != null && item.status.name != params.status) return false;
    if (params.category != null && item.category != params.category) return false;
    if (params.supplierId != null && item.supplierId != params.supplierId) return false;
    if (params.createdBy != null && item.createdBy.id != params.createdBy) return false;
    if (params.branchId != null && item.branchId != params.branchId) return false;
    if (params.docNumber != null && item.docNumber != params.docNumber) return false;

    final createdAt = item.createdAt.millisecondsSinceEpoch;
    if (params.startDate != null && createdAt < params.startDate!) return false;
    if (params.endDate != null && createdAt > params.endDate!) return false;
    if (params.minAmount != null && item.amount < params.minAmount!) return false;
    if (params.maxAmount != null && item.amount > params.maxAmount!) return false;

    return true;
  }

  ExpenseQueryParams _copyQueryParams(ExpenseQueryParams source) {
    return ExpenseQueryParams()
      ..offset = source.offset
      ..limit = source.limit
      ..status = source.status
      ..startDate = source.startDate
      ..endDate = source.endDate
      ..createdBy = source.createdBy
      ..branchId = source.branchId
      ..category = source.category
      ..docNumber = source.docNumber
      ..minAmount = source.minAmount
      ..maxAmount = source.maxAmount
      ..type = source.type
      ..supplierId = source.supplierId;
  }
}
