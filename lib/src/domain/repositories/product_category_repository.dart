import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/product_category/product_category_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ProductCategoriesRepository {
  final ProductCategoriesDataSource productCategoriesDataSource;

  ProductCategoriesRepository(this.productCategoriesDataSource);

  List<ProductCategoryInDb> _productCategories = [];

  List<ProductCategoryInDb> get productCategories => _productCategories;

  Future<ProductCategoryInDb> createProductCategory(CreateProductCategory createProductCategory) async {
    final result = await productCategoriesDataSource.createProductCategory(createProductCategory.toJson());
    final newCategory = ProductCategoryInDb.fromJson(result);
    _productCategories = [newCategory, ..._productCategories];
    return newCategory;
  }

  Future<List<ProductCategoryInDb>> getAllProductCategories() async {
    final results = await productCategoriesDataSource.getAllProductCategories();
    final models = ListResponse<ProductCategoryInDb>.fromJson(
      results,
      ProductCategoryInDb.fromJson,
    );

    _productCategories = models.data;
    _productCategories.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _productCategories;
  }

  Future<ProductCategoryInDb?> getProductCategoryById(String categoryId) async {
    final result = await productCategoriesDataSource.getProductCategoryById(categoryId);
    if (result == null) return null;
    return ProductCategoryInDb.fromJson(result);
  }

  Future<List<ProductCategoryInDb>> searchProductCategoryByKeyword(String keyword) async {
    final result = await productCategoriesDataSource.searchProductCategoryByKeyword(keyword);
    final categories = ListResponse<ProductCategoryInDb>.fromJson(
      result,
      ProductCategoryInDb.fromJson,
    ).data;
    return categories;
  }

  Future<List<ProductCategoryInDb>> searchProductCategoryByKeywordLocal(String keyword) async {
    final result = _productCategories
        .where(
          (cat) => cat.name.toLowerCase().contains(
            keyword.toLowerCase(),
          ),
        )
        .toList();
    return result;
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
    final index = _productCategories.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      _productCategories[index] = updatedCategory;
    }
    return updatedCategory;
  }

  Future<ProductCategoryInDb?> deleteProductCategoryById(String categoryId) async {
    final result = await productCategoriesDataSource.deleteProductCategoryById(categoryId);
    if (result == null) return null;

    final deletedCategory = ProductCategoryInDb.fromJson(result);
    _productCategories.removeWhere((cat) => cat.id == categoryId);
    return deletedCategory;
  }
}
