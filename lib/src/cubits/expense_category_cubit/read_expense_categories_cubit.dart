import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expense_category_model/expense_category_model.dart';
import 'package:kardex_app_front/src/domain/repositories/expense_categories_repository.dart';

part 'read_expense_categories_state.dart';

class ReadExpenseCategoryCubit extends Cubit<ReadExpenseCategoryState> {
  ReadExpenseCategoryCubit(this.expenseCategoriesRepository) : super(ReadExpenseCategoryInitial());

  final ExpenseCategoriesRepository expenseCategoriesRepository;

  Future<void> getAll() async {
    emit(ReadExpenseCategoryLoading());
    try {
      final categories = await expenseCategoriesRepository.getAllExpenseCategories();
      emit(ReadExpenseCategorySuccess(categories));
    } catch (error) {
      emit(ReadExpenseCategoryError(error.toString()));
    }
  }

  Future<void> getById(String expenseCategoryId) async {
    emit(ReadExpenseCategoryLoading());
    try {
      final category = await expenseCategoriesRepository.getExpenseCategoryById(expenseCategoryId);
      if (category != null) {
        emit(ReadExpenseCategorySuccess([category]));
      }
    } catch (error) {
      emit(ReadExpenseCategoryError(error.toString()));
    }
  }

  void searchByKeyword(String keyword) {
    final currentState = state;
    if (currentState is! ReadExpenseCategorySuccess) return;
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
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadExpenseCategorySuccess(items, newItems: newItems));
    }
  }

  void markExpenseCategoryUpdated(ExpenseCategoryInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseCategorySuccess) {
      final updatedItems = [...currentState.updatedItems, item];
      final items = currentState.items.map((element) => element.id == item.id ? item : element).toList();
      emit(ReadExpenseCategorySuccess(items, updatedItems: updatedItems));
    }
  }

  void markExpenseCategoryDeleted(ExpenseCategoryInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseCategorySuccess) {
      final deletedItems = [...currentState.deletedItems, item];
      emit(ReadExpenseCategorySuccess(currentState.items, deletedItems: deletedItems));
    }
  }
}
