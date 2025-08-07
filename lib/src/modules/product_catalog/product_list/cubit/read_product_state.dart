part of 'read_product_cubit.dart';

sealed class ReadProductState {}

final class ReadProductInitial extends ReadProductState {}

final class ReadProductLoading extends ReadProductState {}

class ReadProductSuccess extends ReadProductState {
  final List<ProductInDb> products;
  ReadProductSuccess(this.products);
}

final class ReadProductSearching extends ReadProductSuccess {
  ReadProductSearching(super.products);
}

class HighlightedProduct extends ReadProductSuccess {
  List<ProductInDb> newProducts;
  List<ProductInDb> updatedProducts;
  HighlightedProduct(
    super.products, {
    this.newProducts = const [],
    this.updatedProducts = const [],
  });
}

final class ProductInserted extends ReadProductSuccess {
  int inserted;
  ProductInserted(this.inserted, super.products);
}

final class ProductUpdated extends ReadProductSuccess {
  List<ProductInDb> updated;
  ProductUpdated(this.updated, super.products);
}

final class ProductReadError extends ReadProductState {
  final String message;
  ProductReadError(this.message);
}
