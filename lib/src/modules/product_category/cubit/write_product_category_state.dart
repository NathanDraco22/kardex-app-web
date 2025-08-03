part of 'write_product_category_cubit.dart';

sealed class WriteProductCategoryState {}

final class WriteProductCategoryInitial extends WriteProductCategoryState {}

final class WriteProductCategoryInProgress extends WriteProductCategoryState {}

final class WriteProductCategorySuccess extends WriteProductCategoryState {
  final ProductCategoryInDb productCategory;
  WriteProductCategorySuccess(this.productCategory);
}

final class DeleteProductCategorySuccess extends WriteProductCategoryState {
  final ProductCategoryInDb productCategory;
  DeleteProductCategorySuccess(this.productCategory);
}

final class WriteProductCategoryError extends WriteProductCategoryState {
  final String error;
  WriteProductCategoryError(this.error);
}
