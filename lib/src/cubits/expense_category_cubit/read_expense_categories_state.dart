part of 'read_expense_categories_cubit.dart';

sealed class ReadExpenseCategoryState {}

final class ReadExpenseCategoryInitial extends ReadExpenseCategoryState {}

final class ReadExpenseCategoryLoading extends ReadExpenseCategoryState {}

class ReadExpenseCategorySuccess extends ReadExpenseCategoryState {
  final List<ExpenseCategoryInDb> items;
  List<ExpenseCategoryInDb> newItems;
  List<ExpenseCategoryInDb> updatedItems;
  List<ExpenseCategoryInDb> deletedItems;

  ReadExpenseCategorySuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
  });
}

final class ReadExpenseCategorySearching extends ReadExpenseCategorySuccess {
  ReadExpenseCategorySearching(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

class HighlightedExpenseCategoryItem extends ReadExpenseCategorySuccess {
  HighlightedExpenseCategoryItem(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
  });
}

final class ReadExpenseCategoryError extends ReadExpenseCategoryState {
  final String message;
  ReadExpenseCategoryError(this.message);
}
