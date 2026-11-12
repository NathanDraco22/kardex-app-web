part of 'read_expenses_cubit.dart';

/// Permite distinguir "no modificar el campo" de "establecerlo en null" en
/// los `copyWith`.
const Object _unsetExpenseStateValue = Object();

sealed class ReadExpenseState {}

final class ReadExpenseInitial extends ReadExpenseState {}

final class ReadExpenseLoading extends ReadExpenseState {}

class ReadExpenseSuccess extends ReadExpenseState {
  final List<ExpenseInDb> items;
  final List<ExpenseInDb> newItems;
  final List<ExpenseInDb> updatedItems;
  final List<ExpenseInDb> deletedItems;

  /// Indica que se está pidiendo la siguiente página sin vaciar la lista.
  final bool isLoadingMore;

  /// Indica si el backend podría devolver más registros.
  final bool hasMore;

  /// Cantidad de registros actualmente cargados en la lista.
  final int totalLoaded;

  /// Mensaje de error de la última carga adicional, si falló.
  final String? loadMoreError;

  ReadExpenseSuccess(
    this.items, {
    this.newItems = const [],
    this.updatedItems = const [],
    this.deletedItems = const [],
    this.isLoadingMore = false,
    this.hasMore = false,
    int? totalLoaded,
    this.loadMoreError,
  }) : totalLoaded = totalLoaded ?? items.length;

  ReadExpenseSuccess copyWith({
    List<ExpenseInDb>? items,
    List<ExpenseInDb>? newItems,
    List<ExpenseInDb>? updatedItems,
    List<ExpenseInDb>? deletedItems,
    bool? isLoadingMore,
    bool? hasMore,
    int? totalLoaded,
    Object? loadMoreError = _unsetExpenseStateValue,
  }) {
    return ReadExpenseSuccess(
      items ?? this.items,
      newItems: newItems ?? this.newItems,
      updatedItems: updatedItems ?? this.updatedItems,
      deletedItems: deletedItems ?? this.deletedItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      totalLoaded: totalLoaded ?? this.totalLoaded,
      loadMoreError: identical(loadMoreError, _unsetExpenseStateValue) ? this.loadMoreError : loadMoreError as String?,
    );
  }
}

final class ReadExpenseSearching extends ReadExpenseSuccess {
  ReadExpenseSearching(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
    super.isLoadingMore,
    super.hasMore,
    super.totalLoaded,
    super.loadMoreError,
  });

  @override
  ReadExpenseSearching copyWith({
    List<ExpenseInDb>? items,
    List<ExpenseInDb>? newItems,
    List<ExpenseInDb>? updatedItems,
    List<ExpenseInDb>? deletedItems,
    bool? isLoadingMore,
    bool? hasMore,
    int? totalLoaded,
    Object? loadMoreError = _unsetExpenseStateValue,
  }) {
    return ReadExpenseSearching(
      items ?? this.items,
      newItems: newItems ?? this.newItems,
      updatedItems: updatedItems ?? this.updatedItems,
      deletedItems: deletedItems ?? this.deletedItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      totalLoaded: totalLoaded ?? this.totalLoaded,
      loadMoreError: identical(loadMoreError, _unsetExpenseStateValue) ? this.loadMoreError : loadMoreError as String?,
    );
  }
}

class HighlightedExpenseItem extends ReadExpenseSuccess {
  HighlightedExpenseItem(
    super.items, {
    super.newItems,
    super.updatedItems,
    super.deletedItems,
    super.isLoadingMore,
    super.hasMore,
    super.totalLoaded,
  });
}

final class ReadExpenseError extends ReadExpenseState {
  final String message;
  ReadExpenseError(this.message);
}
