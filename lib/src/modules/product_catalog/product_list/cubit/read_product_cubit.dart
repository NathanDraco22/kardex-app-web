import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_state.dart';

class ReadProductCubit extends Cubit<ReadProductState> {
  ReadProductCubit({
    required this.productsRepository,
    required this.unitsRepository,
    required this.categoriesRepository,
  }) : super(ReadProductInitial());

  final ProductsRepository productsRepository;
  final UnitsRepository unitsRepository;
  final ProductCategoriesRepository categoriesRepository;

  bool isLastPage = false;

  List<ProductInDb> _productsCache = [];

  Future<void> loadPaginatedProducts() async {
    emit(ReadProductLoading());
    try {
      await Future.wait([
        unitsRepository.getAllUnits(),
        categoriesRepository.getAllProductCategories(),
      ]);
      final products = await productsRepository.getPaginatedProducts(_productsCache.length);
      if (products.length < paginationItems) isLastPage = true;
      _productsCache = [..._productsCache, ...products];
      emit(ReadProductSuccess(_productsCache));
    } catch (error) {
      emit(ProductReadError(error.toString()));
    }
  }

  Future<void> getNextPagedProducts() async {
    if (isLastPage) return;
    try {
      final products = await productsRepository.getPaginatedProducts(_productsCache.length);
      if (products.length < paginationItems) isLastPage = true;
      _productsCache = [..._productsCache, ...products];
      emit(ReadProductSuccess(_productsCache));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> searchProductByKeyword(String keyword) async {
    final currentState = state as ReadProductSuccess;

    if (keyword.isEmpty) {
      emit(ReadProductSuccess(_productsCache));
      return;
    }

    emit(ReadProductSearching(currentState.products));
    try {
      final products = await productsRepository.searchProductByKeyword(keyword);
      emit(ReadProductSuccess(products));
    } catch (error) {
      emit(ProductReadError(error.toString()));
    }
  }

  Future<void> putProductFirst(ProductInDb product) async {
    final currentState = state as ReadProductSuccess;
    _productsCache = [product, ..._productsCache];
    final currentProducts = [product, ...currentState.products];
    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          currentProducts,
          newProducts: [product, ...currentState.newProducts],
          updatedProducts: currentState.updatedProducts,
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        currentProducts,
        newProducts: [product],
      ),
    );
  }

  Future<void> markProductUpdated(ProductInDb product) async {
    final currentState = state as ReadProductSuccess;

    final productIndex = _productsCache.indexWhere((element) => element.id == product.id);
    if (productIndex != -1) {
      _productsCache[productIndex] = product;
    }

    final currentProducts = List<ProductInDb>.from(currentState.products);
    final visibleIndex = currentProducts.indexWhere((element) => element.id == product.id);
    if (visibleIndex != -1) {
      currentProducts[visibleIndex] = product;
    }

    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          currentProducts,
          newProducts: currentState.newProducts,
          updatedProducts: [product, ...currentState.updatedProducts],
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        currentProducts,
        updatedProducts: [product],
      ),
    );
  }

  Future<void> removeProduct(ProductInDb product) async {
    final currentState = state as ReadProductSuccess;
    _productsCache.removeWhere((element) => element.id == product.id);
    final currentProducts = List<ProductInDb>.from(currentState.products);
    currentProducts.removeWhere((element) => element.id == product.id);
    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          currentProducts,
          newProducts: currentState.newProducts,
          updatedProducts: currentState.updatedProducts,
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        currentProducts,
      ),
    );
  }
}
