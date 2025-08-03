import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_category/product_category_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_product_category_state.dart';

class WriteProductCategoryCubit extends Cubit<WriteProductCategoryState> {
  WriteProductCategoryCubit(this.productCategoriesRepository) : super(WriteProductCategoryInitial());

  final ProductCategoriesRepository productCategoriesRepository;

  Future<void> createNewProductCategory(CreateProductCategory createProductCategory) async {
    emit(WriteProductCategoryInProgress());
    try {
      final category = await productCategoriesRepository.createProductCategory(createProductCategory);
      emit(WriteProductCategorySuccess(category));
      emit(WriteProductCategoryInitial());
    } catch (error) {
      emit(WriteProductCategoryError(error.toString()));
    }
  }

  Future<void> updateProductCategory(String categoryId, UpdateProductCategory updateProductCategory) async {
    emit(WriteProductCategoryInProgress());
    try {
      final category = await productCategoriesRepository.updateProductCategoryById(categoryId, updateProductCategory);
      emit(WriteProductCategorySuccess(category!));
      emit(WriteProductCategoryInitial());
    } catch (error) {
      emit(WriteProductCategoryError(error.toString()));
    }
  }

  Future<void> deleteProductCategory(String categoryId) async {
    emit(WriteProductCategoryInProgress());
    try {
      final category = await productCategoriesRepository.deleteProductCategoryById(categoryId);
      emit(DeleteProductCategorySuccess(category!));
      emit(WriteProductCategoryInitial());
    } catch (error) {
      emit(WriteProductCategoryError(error.toString()));
    }
  }
}
