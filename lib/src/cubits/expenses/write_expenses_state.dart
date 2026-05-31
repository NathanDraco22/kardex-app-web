part of 'write_expenses_cubit.dart';

sealed class WriteExpenseState {}

final class WriteExpenseInitial extends WriteExpenseState {}

final class WritingExpense extends WriteExpenseState {}

class WriteExpenseSuccess extends WriteExpenseState {
  final ExpenseInDb item;
  WriteExpenseSuccess(this.item);
}

final class ExpenseCreated extends WriteExpenseSuccess {
  ExpenseCreated(super.item);
}

final class ExpenseUpdated extends WriteExpenseSuccess {
  ExpenseUpdated(super.item);
}

final class ExpenseDeleted extends WriteExpenseSuccess {
  ExpenseDeleted(super.item);
}

final class WriteExpenseError extends WriteExpenseState {
  final String message;
  WriteExpenseError(this.message);
}
