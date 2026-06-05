import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/expenses_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/expense_categories_repository.dart';

part 'read_expenses_state.dart';

class ReadExpenseCubit extends Cubit<ReadExpenseState> {
  ReadExpenseCubit(
    this.expensesRepository,
    this.expenseCategoriesRepository,
  ) : super(ReadExpenseInitial());

  final ExpensesRepository expensesRepository;
  final ExpenseCategoriesRepository expenseCategoriesRepository;

  ExpenseQueryParams queryParams = ExpenseQueryParams();

  Future<void> getAll([ExpenseQueryParams? params]) async {
    queryParams = params ?? ExpenseQueryParams();
    if (state is ReadExpenseSuccess) {
      final scopeState = state as ReadExpenseSuccess;
      emit(
        ReadExpenseSearching(
          scopeState.items,
          newItems: scopeState.newItems,
          updatedItems: scopeState.updatedItems,
          deletedItems: scopeState.deletedItems,
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
      final expenses = results[0] as List<ExpenseInDb>;
      emit(ReadExpenseSuccess(expenses));
    } catch (error) {
      emit(ReadExpenseError(error.toString()));
    }
  }

  Future<void> getById(String expenseId) async {
    emit(ReadExpenseLoading());
    try {
      final expense = await expensesRepository.getExpenseById(expenseId);
      if (expense != null) {
        emit(ReadExpenseSuccess([expense]));
      }
    } catch (error) {
      emit(ReadExpenseError(error.toString()));
    }
  }

  void searchByKeyword(String keyword) {
    final currentState = state;
    if (currentState is! ReadExpenseSuccess) return;
    if (keyword.isEmpty) {
      emit(ReadExpenseSuccess(expensesRepository.expenses));
      return;
    }
    emit(ReadExpenseSearching(currentState.items));
    final filtered = expensesRepository.expenses
        .where(
          (e) =>
              e.category.toLowerCase().contains(keyword.toLowerCase()) ||
              e.docNumber.toLowerCase().contains(keyword.toLowerCase()),
        )
        .toList();
    emit(ReadExpenseSuccess(filtered));
  }

  void markExpenseCreated(ExpenseInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseSuccess) {
      final items = [item, ...currentState.items.where((u) => u.id != item.id)];
      final newItems = [...currentState.newItems, item];
      emit(ReadExpenseSuccess(items, newItems: newItems));
    }
  }

  void markExpenseUpdated(ExpenseInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseSuccess) {
      final updatedItems = [...currentState.updatedItems, item];
      final items = currentState.items.map((element) => element.id == item.id ? item : element).toList();
      emit(ReadExpenseSuccess(items, updatedItems: updatedItems));
    }
  }

  void markExpenseDeleted(ExpenseInDb item) {
    final currentState = state;
    if (currentState is ReadExpenseSuccess) {
      final deletedItems = [...currentState.deletedItems, item];
      emit(ReadExpenseSuccess(currentState.items, deletedItems: deletedItems));
    }
  }
}
