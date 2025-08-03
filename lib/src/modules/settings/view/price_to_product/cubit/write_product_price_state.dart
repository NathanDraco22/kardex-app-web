part of 'write_product_price_cubit.dart';

sealed class WriteProductPriceState {}

final class WriteProductPriceInitial extends WriteProductPriceState {}

final class WriteProductPriceInProgress extends WriteProductPriceState {}

final class WriteProductPriceSuccess extends WriteProductPriceState {
  final ProductPriceInDb productPrice;
  WriteProductPriceSuccess(this.productPrice);
}

final class DeleteProductPriceSuccess extends WriteProductPriceState {
  final ProductPriceInDb productPrice;
  DeleteProductPriceSuccess(this.productPrice);
}

final class WriteProductPriceError extends WriteProductPriceState {
  final String error;
  WriteProductPriceError(this.error);
}
