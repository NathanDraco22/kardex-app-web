part of 'supplier_write_cubit.dart';

sealed class SupplierWriteState {}

final class SupplierWriteInitial extends SupplierWriteState {}

final class SupplierWriteInProgress extends SupplierWriteState {}

final class SupplierWriteSuccess extends SupplierWriteState {
  final SupplierInDb supplier;
  SupplierWriteSuccess(this.supplier);
}

final class SupplierWriteError extends SupplierWriteState {
  final String error;
  SupplierWriteError(this.error);
}
