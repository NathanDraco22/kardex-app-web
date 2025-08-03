part of 'supplier_write_cubit.dart';

sealed class WriteSupplierState {}

final class WriteSupplierInitial extends WriteSupplierState {}

final class SupplierWriteInProgress extends WriteSupplierState {}

final class WriteSupplierSuccess extends WriteSupplierState {
  final SupplierInDb supplier;
  WriteSupplierSuccess(this.supplier);
}

final class DeleteSupplierSuccess extends WriteSupplierState {
  final SupplierInDb supplier;
  DeleteSupplierSuccess(this.supplier);
}

final class WriteSupplierError extends WriteSupplierState {
  final String error;
  WriteSupplierError(this.error);
}
