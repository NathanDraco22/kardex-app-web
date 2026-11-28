import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/product_category/product_category_model.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class ProductCategoriesRepository with ReactiveRepository<ProductCategoryInDb> {
  final ProductCategoriesDataSource productCategoriesDataSource;

  ProductCategoriesRepository(this.productCategoriesDataSource);

  Future<ProductCategoryInDb> createProductCategory(
    CreateProductCategory createProductCategory,
  ) async {
    final result = await productCategoriesDataSource.createProductCategory(
      createProductCategory.toJson(),
    );
    final newCategory = ProductCategoryInDb.fromJson(result);
    notifyItemCreated(newCategory);
    return newCategory;
  }

  Future<List<ProductCategoryInDb>> getAllProductCategories() async {
    final results = await productCategoriesDataSource.getAllProductCategories();
    final models = ListResponse<ProductCategoryInDb>.fromJson(
      results,
      ProductCategoryInDb.fromJson,
    );

    return models.data;
  }

  Future<ProductCategoryInDb?> getProductCategoryById(String categoryId) async {
    final result = await productCategoriesDataSource.getProductCategoryById(
      categoryId,
    );
    if (result == null) return null;
    return ProductCategoryInDb.fromJson(result);
  }

  Future<List<ProductCategoryInDb>> searchProductCategoryByKeyword(
    String keyword,
  ) async {
    final result = await productCategoriesDataSource
        .searchProductCategoryByKeyword(keyword);
    final categories = ListResponse<ProductCategoryInDb>.fromJson(
      result,
      ProductCategoryInDb.fromJson,
    ).data;
    return categories;
  }

  Future<ProductCategoryInDb?> updateProductCategoryById(
    String categoryId,
    UpdateProductCategory category,
  ) async {
    final result = await productCategoriesDataSource.updateProductCategoryById(
      categoryId,
      category.toJson(),
    );
    if (result == null) return null;

    final updatedCategory = ProductCategoryInDb.fromJson(result);
    notifyItemUpdated(updatedCategory);
    return updatedCategory;
  }

  Future<ProductCategoryInDb?> deleteProductCategoryById(
    String categoryId,
  ) async {
    final result = await productCategoriesDataSource.deleteProductCategoryById(
      categoryId,
    );
    if (result == null) return null;

    final deletedCategory = ProductCategoryInDb.fromJson(result);
    notifyItemDeleted(deletedCategory);
    return deletedCategory;
  }
}
