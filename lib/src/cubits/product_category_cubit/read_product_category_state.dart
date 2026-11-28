part of 'read_product_category_cubit.dart';

sealed class ReadProductCategoryState {}

final class ReadProductCategoryInitial extends ReadProductCategoryState {}

final class ReadProductCategoryLoading extends ReadProductCategoryState {}

class ReadProductCategorySuccess extends ReadProductCategoryState {
  final List<ProductCategoryInDb> productCategories;
  ReadProductCategorySuccess(this.productCategories);
}

class HighlightedProductCategory extends ReadProductCategorySuccess {
  final List<ProductCategoryInDb> newProductCategories;
  final List<ProductCategoryInDb> updatedProductCategories;

  HighlightedProductCategory(
    super.productCategories, {
    this.newProductCategories = const [],
    this.updatedProductCategories = const [],
  });
}

final class ProductCategoryReadError extends ReadProductCategoryState {
  final String message;
  ProductCategoryReadError(this.message);
}
