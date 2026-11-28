import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/cubits/product_category_cubit/read_product_category_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeProductCategoriesRepository
    with ReactiveRepository<ProductCategoryInDb>
    implements ProductCategoriesRepository {
  _FakeProductCategoriesRepository(this.categories);

  List<ProductCategoryInDb> categories;
  int getAllProductCategoriesCalls = 0;

  @override
  Future<List<ProductCategoryInDb>> getAllProductCategories() async {
    getAllProductCategoriesCalls++;
    return List<ProductCategoryInDb>.from(categories);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProductCategoryInDb _buildCategory(String id, String name) {
  return ProductCategoryInDb(
    id: id,
    name: name,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('carga inicial y agrega categorías creadas sin volver a consultar', () async {
    final repository = _FakeProductCategoriesRepository([
      _buildCategory('category-1', 'Mayoristas'),
    ]);
    final cubit = ReadProductCategoryCubit(repository);
    addTearDown(() async {
      await cubit.close();
      repository.disposeReactiveRepo();
    });

    await cubit.loadAllProductCategories();

    expect(cubit.state, isA<ReadProductCategorySuccess>());
    expect((cubit.state as ReadProductCategorySuccess).productCategories, hasLength(1));
    expect(repository.getAllProductCategoriesCalls, 1);

    repository.notifyItemCreated(_buildCategory('category-2', 'Almacenes'));
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as ReadProductCategorySuccess;
    expect(state, isA<HighlightedProductCategory>());
    expect(state.productCategories, hasLength(2));
    expect(state.productCategories.map((category) => category.id), containsAll(['category-1', 'category-2']));
    expect(state.productCategories.map((category) => category.name), ['Almacenes', 'Mayoristas']);
    expect((state as HighlightedProductCategory).newProductCategories.map((category) => category.id), ['category-2']);
    expect(repository.getAllProductCategoriesCalls, 1);
  });

  test('ensureLoaded no vuelve a consultar cuando ya se cargaron las categorías', () async {
    final repository = _FakeProductCategoriesRepository([
      _buildCategory('category-1', 'Mayoristas'),
    ]);
    final cubit = ReadProductCategoryCubit(repository);
    addTearDown(() async {
      await cubit.close();
      repository.disposeReactiveRepo();
    });

    await cubit.ensureLoaded();
    await cubit.ensureLoaded();

    expect(cubit.state, isA<ReadProductCategorySuccess>());
    expect(repository.getAllProductCategoriesCalls, 1);
  });
}
