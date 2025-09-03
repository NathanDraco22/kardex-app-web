part of 'read_current_inventory_cubit.dart';

sealed class ReadCurrentInventoryState {}

final class ReadCurrentInventoryInitial extends ReadCurrentInventoryState {}

final class ReadCurrentInventoryLoading extends ReadCurrentInventoryState {}

final class ReadCurrentInventorySuccess extends ReadCurrentInventoryState {
  final List<InventoryInDb> inventories;
  ReadCurrentInventorySuccess(this.inventories);

  int get total {
    if (inventories.isEmpty) return 0;
    final totals = inventories.map((e) => e.total).toList();
    return totals.reduce((value, element) => value + element);
  }
}

final class ReadCurrentInventoryError extends ReadCurrentInventoryState {
  final String message;
  ReadCurrentInventoryError(this.message);
}
