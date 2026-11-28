import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_category_state.dart';

class ReadProductCategoryCubit extends Cubit<ReadProductCategoryState> {
  ReadProductCategoryCubit(this._repository) : super(ReadProductCategoryInitial()) {
    _subscription = _repository.eventStream.listen(_handleRepoEvent);
  }

  final ProductCategoriesRepository _repository;
  StreamSubscription<RepoEvent<ProductCategoryInDb>>? _subscription;

  List<ProductCategoryInDb> _productCategories = [];
  List<ProductCategoryInDb> _newProductCategories = [];
  List<ProductCategoryInDb> _updatedProductCategories = [];
  int _generation = 0;
  bool _hasLoaded = false;
  bool _isLoading = false;

  void _handleRepoEvent(RepoEvent<ProductCategoryInDb> event) {
    if (!_hasLoaded) return;

    switch (event) {
      case RepoItemCreated(:final item):
        final categories = [item, ..._productCategories.where((category) => category.id != item.id)];
        _newProductCategories = [
          item,
          ..._newProductCategories.where((category) => category.id != item.id),
        ];
        _updatedProductCategories = _updatedProductCategories.where((category) => category.id != item.id).toList();
        _emitHighlighted(categories);
      case RepoItemUpdated(:final item):
        final exists = _productCategories.any((category) => category.id == item.id);
        final categories = exists
            ? _productCategories.map((category) => category.id == item.id ? item : category).toList()
            : [item, ..._productCategories];
        _newProductCategories = _newProductCategories.where((category) => category.id != item.id).toList();
        _updatedProductCategories = [
          item,
          ..._updatedProductCategories.where((category) => category.id != item.id),
        ];
        _emitHighlighted(categories);
      case RepoItemDeleted(:final item):
        final categories = _productCategories.where((category) => category.id != item.id).toList();
        _newProductCategories = _newProductCategories.where((category) => category.id != item.id).toList();
        _updatedProductCategories = _updatedProductCategories.where((category) => category.id != item.id).toList();
        _emitHighlighted(categories);
    }
  }

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;
    await loadAllProductCategories();
  }

  Future<void> loadAllProductCategories() async {
    final generation = ++_generation;
    _isLoading = true;
    emit(ReadProductCategoryLoading());

    try {
      final categories = await _repository.getAllProductCategories();
      if (isClosed || generation != _generation) return;

      _productCategories = _sorted(categories);
      _newProductCategories = [];
      _updatedProductCategories = [];
      _hasLoaded = true;
      _isLoading = false;
      emit(ReadProductCategorySuccess(List.unmodifiable(_productCategories)));
    } catch (error) {
      if (isClosed || generation != _generation) return;

      _isLoading = false;
      emit(ProductCategoryReadError(error.toString()));
    }
  }

  void clear() {
    _generation++;
    _hasLoaded = false;
    _isLoading = false;
    _productCategories = [];
    _newProductCategories = [];
    _updatedProductCategories = [];
    if (!isClosed) {
      emit(ReadProductCategoryInitial());
    }
  }

  List<ProductCategoryInDb> _sorted(List<ProductCategoryInDb> categories) {
    final sortedCategories = List<ProductCategoryInDb>.from(categories);
    sortedCategories.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sortedCategories;
  }

  void _emitHighlighted(List<ProductCategoryInDb> categories) {
    _productCategories = _sorted(categories);
    if (!isClosed) {
      emit(
        HighlightedProductCategory(
          List.unmodifiable(_productCategories),
          newProductCategories: List.unmodifiable(_newProductCategories),
          updatedProductCategories: List.unmodifiable(_updatedProductCategories),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
