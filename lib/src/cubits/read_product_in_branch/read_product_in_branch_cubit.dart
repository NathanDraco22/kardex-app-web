import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_in_branch_state.dart';

class ReadProductInBranchCubit extends Cubit<ReadProductInBranchState> {
  ReadProductInBranchCubit({
    required this.productsRepository,
    this.unitsRepository,
    this.categoriesRepository,
  }) : super(ReadProductInBranchInitial());

  final ProductsRepository productsRepository;
  final UnitsRepository? unitsRepository;
  final ProductCategoriesRepository? categoriesRepository;

  ProductQueryParams _params = ProductQueryParams(offset: 0, limit: 50);
  bool isLastPage = false;

  Future<void> getProducts(String branchId, {ProductQueryParams? params}) async {
    emit(ReadProductInBranchLoading());
    _params = params ?? ProductQueryParams(offset: 0, limit: 50, branchId: branchId);
    isLastPage = false;

    try {
      if (unitsRepository != null || categoriesRepository != null) {
        await Future.wait([
          if (unitsRepository != null) unitsRepository!.getAllUnits(),
          if (categoriesRepository != null) categoriesRepository!.getAllProductCategories(),
        ]);
      }

      final products = await productsRepository.getAllProductsInBranch(_params, branchId);

      if (products.length < _params.limit) {
        isLastPage = true;
      }

      _params = ProductQueryParams(
        offset: _params.offset + products.length,
        limit: _params.limit,
        branchId: _params.branchId,
      );

      emit(ReadProductInBranchSuccess(products: products, editedProducts: []));
    } catch (e) {
      emit(ReadProductInBranchFailure(message: e.toString()));
    }
  }

  Future<void> getNextPage(String branchId) async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadProductInBranchSuccess) return;
    if (currentState is ReadProductInBranchFetchingMore) return;

    emit(
      ReadProductInBranchFetchingMore(
        products: currentState.products,
        editedProducts: currentState.editedProducts,
        newProducts: currentState.newProducts,
      ),
    );

    try {
      final products = await productsRepository.getAllProductsInBranch(_params, branchId);

      if (products.length < _params.limit) {
        isLastPage = true;
      }

      _params = ProductQueryParams(
        offset: _params.offset + products.length,
        limit: _params.limit,
        branchId: branchId,
      );

      emit(
        ReadProductInBranchSuccess(
          products: [...currentState.products, ...products],
          editedProducts: currentState.editedProducts,
          newProducts: currentState.newProducts,
        ),
      );
    } catch (e) {
      emit(
        ReadProductInBranchErrorPagination(
          message: e.toString(),
          products: currentState.products,
          editedProducts: currentState.editedProducts,
          newProducts: currentState.newProducts,
        ),
      );
    }
  }

  void putProductFirst(ProductInDbInBranch product) {
    if (state is! ReadProductInBranchSuccess) {
      emit(
        ReadProductInBranchSuccess(
          products: [product],
          editedProducts: const [],
          newProducts: [product],
        ),
      );
      return;
    }
    final currentState = state as ReadProductInBranchSuccess;

    final currentProducts = [
      product,
      ...currentState.products.where((p) => p.id != product.id),
    ];
    final currentNew = [
      product,
      ...currentState.newProducts.where((p) => p.id != product.id),
    ];

    emit(
      ReadProductInBranchSuccess(
        products: currentProducts,
        editedProducts: currentState.editedProducts,
        newProducts: currentNew,
      ),
    );
  }

  void markProductAsEdited(ProductInDbInBranch product) {
    if (state is! ReadProductInBranchSuccess) return;
    final currentState = state as ReadProductInBranchSuccess;

    final currentEdited = List<ProductInDbInBranch>.from(currentState.editedProducts);

    final index = currentEdited.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      currentEdited[index] = product;
    } else {
      currentEdited.add(product);
    }

    emit(
      ReadProductInBranchSuccess(
        products: currentState.products,
        editedProducts: currentEdited,
        newProducts: currentState.newProducts,
      ),
    );
  }
}
