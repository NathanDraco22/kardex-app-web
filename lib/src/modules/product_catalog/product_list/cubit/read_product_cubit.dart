import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_state.dart';

class ReadProductCubit extends Cubit<ReadProductState> {
  ReadProductCubit({
    required this.productsRepository,
    required this.unitsRepository,
    this.branchId,
  }) : super(ReadProductInitial());

  final ProductsRepository productsRepository;
  final UnitsRepository unitsRepository;
  final String? branchId;

  bool isLastPage = false;
  ProductType? selectedTypeFilter;
  String _lastKeyword = '';

  List<ProductInDb> _productsCache = [];

  String? get _activeBranchId {
    if (branchId != null && branchId!.isNotEmpty) return branchId;
    if (getIt.isRegistered<AuthCubit>()) {
      final authState = getIt<AuthCubit>().state;
      if (authState is Authenticated) return authState.branch.id;
    }
    return null;
  }

  Future<void> loadPaginatedProducts({ProductType? productType, bool reset = false}) async {
    if (reset) {
      _productsCache = [];
      isLastPage = false;
      selectedTypeFilter = productType;
    }
    emit(ReadProductLoading());
    try {
      await unitsRepository.getAllUnits();
      final products = await productsRepository.getPaginatedProducts(
        _productsCache.length,
        branchId: _activeBranchId,
        productType: selectedTypeFilter,
      );
      if (products.length < paginationItems) isLastPage = true;
      _productsCache = [..._productsCache, ...products];
      emit(ReadProductSuccess(_productsCache));
    } catch (error) {
      emit(ProductReadError(error.toString()));
    }
  }

  Future<void> setTypeFilter(ProductType? productType) async {
    selectedTypeFilter = productType;
    if (_lastKeyword.isNotEmpty) {
      await searchProductByKeyword(_lastKeyword);
      return;
    }
    await loadPaginatedProducts(productType: productType, reset: true);
  }

  Future<void> getNextPagedProducts() async {
    if (isLastPage || _lastKeyword.isNotEmpty) return;
    try {
      final products = await productsRepository.getPaginatedProducts(
        _productsCache.length,
        branchId: _activeBranchId,
        productType: selectedTypeFilter,
      );
      if (products.length < paginationItems) isLastPage = true;
      _productsCache = [..._productsCache, ...products];
      emit(ReadProductSuccess(_productsCache));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> searchProductByKeyword(String keyword) async {
    _lastKeyword = keyword.trim();
    final currentState = state as ReadProductSuccess;

    if (_lastKeyword.isEmpty) {
      emit(ReadProductSuccess(_productsCache));
      return;
    }

    emit(ReadProductSearching(currentState.products));
    try {
      final products = await productsRepository.searchProductByKeyword(
        _lastKeyword,
        branchId: _activeBranchId,
        productType: selectedTypeFilter,
      );
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
