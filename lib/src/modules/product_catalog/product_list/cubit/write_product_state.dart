part of 'write_product_cubit.dart';

sealed class WriteProductState {}

final class WriteProductInitial extends WriteProductState {}

final class WriteProductInProgress extends WriteProductState {}

final class WriteProductSuccess extends WriteProductState {
  final ProductInDb product;
  WriteProductSuccess(this.product);
}

final class DeleteProductSuccess extends WriteProductState {
  final ProductInDb product;
  DeleteProductSuccess(this.product);
}

final class WriteProductError extends WriteProductState {
  final String error;
  WriteProductError(this.error);
}
