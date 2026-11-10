import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

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

  Future<bool> update(String expenseId, UpdateExpense expense) async {
    emit(WritingExpense());
    try {
      final updated = await expensesRepository.updateExpenseById(expenseId, expense);
      if (updated == null) {
        emit(WriteExpenseError('No se pudo actualizar el gasto.'));
        return false;
      }

      emit(ExpenseUpdated(updated));
      emit(WriteExpenseInitial());
      return true;
    } catch (error) {
      emit(WriteExpenseError(error.toString()));
      return false;
    }
  }

  Future<bool> delete(String expenseId) async {
    emit(WritingExpense());
    try {
      final deleted = await expensesRepository.deleteExpenseById(expenseId);
      if (deleted == null) {
        emit(WriteExpenseError('No se pudo eliminar el gasto.'));
        return false;
      }

      emit(ExpenseDeleted(deleted));
      emit(WriteExpenseInitial());
      return true;
    } catch (error) {
      emit(WriteExpenseError(error.toString()));
      return false;
    }
  }
}
