import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/repositories/expenses_repository.dart';

part 'write_expenses_state.dart';

class WriteExpenseCubit extends Cubit<WriteExpenseState> {
  WriteExpenseCubit(this.expensesRepository) : super(WriteExpenseInitial());

  final ExpensesRepository expensesRepository;

  Future<void> create(CreateExpense createExpense) async {
    emit(WritingExpense());
    try {
      final expense = await expensesRepository.createExpense(createExpense);
      emit(ExpenseCreated(expense));
      emit(WriteExpenseInitial());
    } catch (error) {
      emit(WriteExpenseError(error.toString()));
    }
  }

  Future<void> update(String expenseId, UpdateExpense expense) async {
    emit(WritingExpense());
    try {
      final updated = await expensesRepository.updateExpenseById(expenseId, expense);
      if (updated != null) {
        emit(ExpenseUpdated(updated));
        emit(WriteExpenseInitial());
      }
    } catch (error) {
      emit(WriteExpenseError(error.toString()));
    }
  }

  Future<void> delete(String expenseId) async {
    emit(WritingExpense());
    try {
      final deleted = await expensesRepository.deleteExpenseById(expenseId);
      if (deleted != null) {
        emit(ExpenseDeleted(deleted));
        emit(WriteExpenseInitial());
      }
    } catch (error) {
      emit(WriteExpenseError(error.toString()));
    }
  }
}
