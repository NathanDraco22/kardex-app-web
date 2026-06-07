part of 'write_expense_categories_cubit.dart';

sealed class WriteExpenseCategoryState {}

final class WriteExpenseCategoryInitial extends WriteExpenseCategoryState {}

final class WritingExpenseCategory extends WriteExpenseCategoryState {}

class WriteExpenseCategorySuccess extends WriteExpenseCategoryState {
  final ExpenseCategoryInDb item;
  WriteExpenseCategorySuccess(this.item);
}

final class ExpenseCategoryCreated extends WriteExpenseCategorySuccess {
  ExpenseCategoryCreated(super.item);
}

final class ExpenseCategoryUpdated extends WriteExpenseCategorySuccess {
  ExpenseCategoryUpdated(super.item);
}

final class ExpenseCategoryDeleted extends WriteExpenseCategorySuccess {
  ExpenseCategoryDeleted(super.item);
}

final class WriteExpenseCategoryError extends WriteExpenseCategoryState {
  final String message;
  WriteExpenseCategoryError(this.message);
}
