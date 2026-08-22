import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_terminal_product_state.dart';

class ReadTerminalProductCubit extends Cubit<ReadTerminalProductState> {
  ReadTerminalProductCubit({
    required this.productsRepository,
    required this.branchId,
  }) : super(ReadTerminalProductInitial());

  final ProductsRepository productsRepository;
  final String branchId;

  bool isLastPage = false;
  bool _isSearching = false;

  List<ProductInDbInBranch> _productsCache = [];

  Future<void> loadProducts() async {
    emit(ReadTerminalProductLoading());
    try {
      final products = await productsRepository.getAllProductsInBranch(
        ProductQueryParams(offset: 0, limit: paginationItems),
        branchId,
      );
      _productsCache = products;
      isLastPage = products.length < paginationItems;
      emit(ReadTerminalProductSuccess(_productsCache));
    } catch (error) {
      emit(ReadTerminalProductError(error.toString()));
    }
  }

  Future<void> getNextPagedProducts() async {
    if (isLastPage || _isSearching) return;
    try {
      final products = await productsRepository.getAllProductsInBranch(
        ProductQueryParams(offset: _productsCache.length, limit: paginationItems),
        branchId,
      );
      if (products.length < paginationItems) isLastPage = true;
      _productsCache = [..._productsCache, ...products];
      emit(ReadTerminalProductSuccess(_productsCache));
    } catch (error) {
      log(error.toString());
    }
  }

  Future<List<ProductInDbInBranch>> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      _isSearching = false;
      emit(ReadTerminalProductSuccess(_productsCache));
      return _productsCache;
    }

    if (state is ReadTerminalProductSuccess) {
      emit(ReadTerminalProductSearching((state as ReadTerminalProductSuccess).products));
    }

    _isSearching = true;
    try {
      final results = await productsRepository.searchProductInBranch(keyword.trim(), branchId);
      emit(ReadTerminalProductSuccess(results));
      return results;
    } catch (error) {
      emit(ReadTerminalProductError(error.toString()));
      return [];
    } finally {
      _isSearching = false;
    }
  }
}
