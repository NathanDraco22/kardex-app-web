part of 'write_product_category_cubit.dart';

sealed class ProductCategoryWriteState {}

final class ProductCategoryWriteInitial extends ProductCategoryWriteState {}

final class ProductCategoryWriteInProgress extends ProductCategoryWriteState {}

final class ProductCategoryWriteSuccess extends ProductCategoryWriteState {
  final ProductCategoryInDb productCategory;
  ProductCategoryWriteSuccess(this.productCategory);
}

final class ProductCategoryDeleteSuccess extends ProductCategoryWriteState {
  final ProductCategoryInDb productCategory;
  ProductCategoryDeleteSuccess(this.productCategory);
}

final class ProductCategoryWriteError extends ProductCategoryWriteState {
  final String error;
  ProductCategoryWriteError(this.error);
}
