part of 'read_expenses_cubit.dart';

sealed class ReadExpenseState {}

final class ReadExpenseInitial extends ReadExpenseState {}

final class ReadExpenseLoading extends ReadExpenseState {}

class ReadExpenseSuccess extends ReadExpenseState {
  final List<ExpenseInDb> items;
  List<ExpenseInDb> newItems;
  List<ExpenseInDb> updatedItems;
  List<ExpenseInDb> deletedItems;

  ReadExpenseSuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
  });
}

final class ReadExpenseSearching extends ReadExpenseSuccess {
  ReadExpenseSearching(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

class HighlightedExpenseItem extends ReadExpenseSuccess {
  HighlightedExpenseItem(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

final class ReadExpenseError extends ReadExpenseState {
  final String message;
  ReadExpenseError(this.message);
}
