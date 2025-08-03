part of 'read_product_price_cubit.dart';

sealed class ReadProductPriceState {}

final class ReadProductPriceInitial extends ReadProductPriceState {}

final class ReadProductPriceLoading extends ReadProductPriceState {}

class ReadProductPriceSuccess extends ReadProductPriceState {
  final List<ProductPriceInDb> productPrices;
  ReadProductPriceSuccess(this.productPrices);
}

final class ProductPriceReadSearching extends ReadProductPriceSuccess {
  ProductPriceReadSearching(super.productPrices);
}

class HighlightedProductPrice extends ReadProductPriceSuccess {
  List<ProductPriceInDb> newProductPrices;
  List<ProductPriceInDb> updatedProductPrices;
  HighlightedProductPrice(
    super.productPrices, {
    this.newProductPrices = const [],
    this.updatedProductPrices = const [],
  });
}

final class ProductPriceInserted extends ReadProductPriceSuccess {
  int inserted;
  ProductPriceInserted(this.inserted, super.productPrices);
}

final class ProductPriceUpdated extends ReadProductPriceSuccess {
  List<ProductPriceInDb> updated;
  ProductPriceUpdated(this.updated, super.productPrices);
}

final class ProductPriceReadError extends ReadProductPriceState {
  final String message;
  ProductPriceReadError(this.message);
}
