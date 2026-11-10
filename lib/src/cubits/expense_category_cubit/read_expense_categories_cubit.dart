import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_expense_categories_state.dart';

class ReadExpenseCategoryCubit extends Cubit<ReadExpenseCategoryState> {
  ReadExpenseCategoryCubit(this.expenseCategoriesRepository) : super(ReadExpenseCategoryInitial());

  final ExpenseCategoriesRepository expenseCategoriesRepository;

  /// Identificador de la última petición de lectura. Las respuestas que
  /// terminan con una generación anterior se descartan.
  int _requestGeneration = 0;

  bool _isCurrent(int generation) => !isClosed && generation == _requestGeneration;

  Future<void> getAll() async {
    final generation = ++_requestGeneration;
    emit(ReadExpenseCategoryLoading());
    try {
      final categories = await expenseCategoriesRepository.getAllExpenseCategories();
      if (!_isCurrent(generation)) return;
      emit(ReadExpenseCategorySuccess(categories));
    } catch (error) {
      if (!_isCurrent(generation)) return;
      emit(ReadExpenseCategoryError(error.toString()));
    }
  }

  /// Recarga las categorías conservando la lista visible mientras llega la
  /// respuesta, para no vaciar la pantalla durante un refresco.
  ///
  /// Si falla y ya había una lista, emite ese mismo estado con
  /// [ReadExpenseCategorySuccess.refreshError] para que la vista muestre un
  /// aviso sin perder los datos.
  Future<void> refresh() async {
    final generation = ++_requestGeneration;
    final previousState = state is ReadExpenseCategorySuccess ? state as ReadExpenseCategorySuccess : null;

    if (previousState != null) {
      emit(
        ReadExpenseCategorySearching(
          previousState.items,
          newItems: previousState.newItems,
          updatedItems: previousState.updatedItems,
          deletedItems: previousState.deletedItems,
        ),
      );
    } else {
      emit(ReadExpenseCategoryLoading());
    }

    try {
      final categories = await expenseCategoriesRepository.getAllExpenseCategories();
      if (!_isCurrent(generation)) return;
      emit(ReadExpenseCategorySuccess(categories));
    } catch (error) {
      if (!_isCurrent(generation)) return;
      if (previousState != null) {
        emit(previousState.copyWith(refreshError: error.toString()));
      } else {
        emit(ReadExpenseCategoryError(error.toString()));
      }
    }
  }

  Future<void> getById(String expenseCategoryId) async {
    final generation = ++_requestGeneration;
    emit(ReadExpenseCategoryLoading());
    try {
      final category = await expenseCategoriesRepository.getExpenseCategoryById(expenseCategoryId);
      if (!_isCurrent(generation)) return;
      if (category != null) {
        emit(ReadExpenseCategorySuccess([category]));
      }
    } catch (error) {
      if (!_isCurrent(generation)) return;
      emit(ReadExpenseCategoryError(error.toString()));
    }
  }

  void searchByKeyword(String keyword) {
    final currentState = state;
    if (currentState is! ReadExpenseCategorySuccess) return;
    _requestGeneration++;
    if (keyword.isEmpty) {
      emit(ReadExpenseCategorySuccess(expenseCategoriesRepository.expenseCategories));
      return;
    }
    emit(ReadExpenseCategorySearching(currentState.items));
    final filtered = expenseCategoriesRepository.expenseCategories
        .where((e) => e.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    emit(ReadExpenseCategorySuccess(filtered));
  }

  void markExpenseCategoryCreated(ExpenseCategoryInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseCategorySuccess) {
      _requestGeneration++;
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadExpenseCategorySuccess(items, newItems: newItems));
    }
  }

  void markExpenseCategoryUpdated(ExpenseCategoryInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseCategorySuccess) {
      _requestGeneration++;
      final updatedItems = [...currentState.updatedItems, item];
      final items = currentState.items.map((element) => element.id == item.id ? item : element).toList();
      emit(ReadExpenseCategorySuccess(items, updatedItems: updatedItems));
    }
  }

  void markExpenseCategoryDeleted(ExpenseCategoryInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseCategorySuccess) {
      _requestGeneration++;
      final deletedItems = [...currentState.deletedItems, item];
      emit(ReadExpenseCategorySuccess(currentState.items, deletedItems: deletedItems));
    }
  }
}
