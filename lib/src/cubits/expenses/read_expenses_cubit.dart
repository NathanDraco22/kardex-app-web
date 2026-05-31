import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/expenses_repository.dart';

part 'read_expenses_state.dart';

class ReadExpenseCubit extends Cubit<ReadExpenseState> {
  ReadExpenseCubit(this.expensesRepository) : super(ReadExpenseInitial());

  final ExpensesRepository expensesRepository;

  Future<void> getAll([ExpenseQueryParams? params]) async {
    emit(ReadExpenseLoading());
    try {
      final expenses = await expensesRepository.getAllExpenses(params ?? ExpenseQueryParams());
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
      emit(ReadExpenseSuccess(currentState.items, updatedItems: updatedItems));
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
