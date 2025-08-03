part of 'read_product_category_cubit.dart';

sealed class ReadProductCategoryState {}

final class ReadProductCategoryInitial extends ReadProductCategoryState {}

final class ReadProductCategoryLoading extends ReadProductCategoryState {}

class ReadProductCategorySuccess extends ReadProductCategoryState {
  final List<ProductCategoryInDb> productCategories;
  ReadProductCategorySuccess(this.productCategories);
}

final class ProductCategoryReadSearching extends ReadProductCategorySuccess {
  ProductCategoryReadSearching(super.productCategories);
}

class HighlightedProductCategory extends ReadProductCategorySuccess {
  List<ProductCategoryInDb> newProductCategories;
  List<ProductCategoryInDb> updatedProductCategories;
  HighlightedProductCategory(
    super.productCategories, {
    this.newProductCategories = const [],
    this.updatedProductCategories = const [],
  });
}

final class ProductCategoryInserted extends ReadProductCategorySuccess {
  int inserted;
  ProductCategoryInserted(this.inserted, super.productCategories);
}

final class ProductCategoryUpdated extends ReadProductCategorySuccess {
  List<ProductCategoryInDb> updated;
  ProductCategoryUpdated(this.updated, super.productCategories);
}

final class ProductCategoryReadError extends ReadProductCategoryState {
  final String message;
  ProductCategoryReadError(this.message);
}
