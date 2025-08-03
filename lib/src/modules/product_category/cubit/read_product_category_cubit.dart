import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_category/product_category_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_product_category_state.dart';

class ReadProductCategoryCubit extends Cubit<ReadProductCategoryState> {
  ReadProductCategoryCubit(this.productCategoriesRepository) : super(ReadProductCategoryInitial());

  final ProductCategoriesRepository productCategoriesRepository;

  Future<void> loadAllProductCategories() async {
    emit(ReadProductCategoryLoading());
    try {
      final categories = await productCategoriesRepository.getAllProductCategories();
      emit(ReadProductCategorySuccess(categories));
    } catch (error) {
      emit(ProductCategoryReadError(error.toString()));
    }
  }

  Future<void> searchProductCategoryByKeyword(String keyword) async {
    final currentState = state as ReadProductCategorySuccess;

    if (keyword.isEmpty) {
      emit(ReadProductCategorySuccess(productCategoriesRepository.productCategories));
      return;
    }

    emit(ProductCategoryReadSearching(currentState.productCategories));
    try {
      final categories = await productCategoriesRepository.searchProductCategoryByKeyword(keyword);
      emit(ReadProductCategorySuccess(categories));
    } catch (error) {
      emit(ProductCategoryReadError(error.toString()));
    }
  }

  Future<void> putProductCategoryFirst(ProductCategoryInDb category) async {
    final currentState = state as ReadProductCategorySuccess;
    final freshList = productCategoriesRepository.productCategories;
    if (currentState is HighlightedProductCategory) {
      emit(
        HighlightedProductCategory(
          freshList,
          newProductCategories: [category, ...currentState.newProductCategories],
          updatedProductCategories: currentState.updatedProductCategories,
        ),
      );
      return;
    }
    emit(
      HighlightedProductCategory(
        freshList,
        newProductCategories: [category],
      ),
    );
  }

  Future<void> markProductCategoryUpdated(ProductCategoryInDb category) async {
    final currentState = state as ReadProductCategorySuccess;
    final freshList = productCategoriesRepository.productCategories;

    if (currentState is HighlightedProductCategory) {
      emit(
        HighlightedProductCategory(
          freshList,
          newProductCategories: currentState.newProductCategories,
          updatedProductCategories: [category, ...currentState.updatedProductCategories],
        ),
      );
      return;
    }
    emit(
      HighlightedProductCategory(
        freshList,
        updatedProductCategories: [category],
      ),
    );
  }

  Future<void> refreshProductCategory() async {
    final currentState = state as ReadProductCategorySuccess;
    final freshList = productCategoriesRepository.productCategories;
    if (currentState is HighlightedProductCategory) {
      emit(
        HighlightedProductCategory(
          freshList,
          newProductCategories: currentState.newProductCategories,
          updatedProductCategories: currentState.updatedProductCategories,
        ),
      );
      return;
    }
    emit(
      HighlightedProductCategory(
        freshList,
      ),
    );
  }
}
