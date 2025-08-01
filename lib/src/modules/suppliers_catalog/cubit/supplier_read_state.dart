part of 'supplier_read_cubit.dart';

sealed class ReadSupplierState {}

final class ReadSupplierInitial extends ReadSupplierState {}

final class ReadSupplierLoading extends ReadSupplierState {}

class ReadSupplierSuccess extends ReadSupplierState {
  final List<SupplierInDb> suppliers;
  ReadSupplierSuccess(this.suppliers);
}

final class ReadSupplierSearching extends ReadSupplierSuccess {
  ReadSupplierSearching(super.suppliers);
}

class HighlightedSupplier extends ReadSupplierSuccess {
  List<SupplierInDb> newSuppliers;
  List<SupplierInDb> updatedSuppliers;
  HighlightedSupplier(
    super.suppliers, {
    this.newSuppliers = const [],
    this.updatedSuppliers = const [],
  });
}

final class SupplierInserted extends ReadSupplierSuccess {
  int inserted;
  SupplierInserted(this.inserted, super.suppliers);
}

final class SupplierUpdated extends ReadSupplierSuccess {
  List<SupplierInDb> updated;
  SupplierUpdated(this.updated, super.suppliers);
}

final class SupplierReadError extends ReadSupplierState {
  final String message;
  SupplierReadError(this.message);
}
