part of 'read_expense_categories_cubit.dart';

sealed class ReadExpenseCategoryState {}

final class ReadExpenseCategoryInitial extends ReadExpenseCategoryState {}

final class ReadExpenseCategoryLoading extends ReadExpenseCategoryState {}

class ReadExpenseCategorySuccess extends ReadExpenseCategoryState {
  final List<ExpenseCategoryInDb> items;
  List<ExpenseCategoryInDb> newItems;
  List<ExpenseCategoryInDb> updatedItems;
  List<ExpenseCategoryInDb> deletedItems;

  /// Error de la última recarga, conservando [items] si ya había datos.
  final String? refreshError;

  ReadExpenseCategorySuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
    this.refreshError,
  });

  ReadExpenseCategorySuccess copyWith({
    List<ExpenseCategoryInDb>? items,
    List<ExpenseCategoryInDb>? newItems,
    List<ExpenseCategoryInDb>? updatedItems,
    List<ExpenseCategoryInDb>? deletedItems,
    String? refreshError,
  }) {
    return ReadExpenseCategorySuccess(
      items ?? this.items,
      newItems: newItems ?? this.newItems,
      updatedItems: updatedItems ?? this.updatedItems,
      deletedItems: deletedItems ?? this.deletedItems,
      refreshError: refreshError ?? this.refreshError,
    );
  }
}

final class ReadExpenseCategorySearching extends ReadExpenseCategorySuccess {
  ReadExpenseCategorySearching(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
    super.refreshError,
  });
}

class HighlightedExpenseCategoryItem extends ReadExpenseCategorySuccess {
  HighlightedExpenseCategoryItem(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
    super.refreshError,
  });
}

final class ReadExpenseCategoryError extends ReadExpenseCategoryState {
  final String message;
  ReadExpenseCategoryError(this.message);
}
