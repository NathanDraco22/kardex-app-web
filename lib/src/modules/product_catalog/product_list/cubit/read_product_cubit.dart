import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_product_state.dart';

class ReadProductCubit extends Cubit<ReadProductState> {
  ReadProductCubit(this.productsRepository) : super(ReadProductInitial());

  final ProductsRepository productsRepository;

  Future<void> loadAllProducts() async {
    emit(ReadProductLoading());
    try {
      final products = await productsRepository.getAllProducts();
      emit(ReadProductSuccess(products));
    } catch (error) {
      emit(ProductReadError(error.toString()));
    }
  }

  Future<void> searchProductByKeyword(String keyword) async {
    final currentState = state as ReadProductSuccess;

    if (keyword.isEmpty) {
      emit(ReadProductSuccess(productsRepository.products));
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
    final freshList = productsRepository.products;
    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          freshList,
          newProducts: [product, ...currentState.newProducts],
          updatedProducts: currentState.updatedProducts,
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        freshList,
        newProducts: [product],
      ),
    );
  }

  Future<void> markProductUpdated(ProductInDb product) async {
    final currentState = state as ReadProductSuccess;
    final freshList = productsRepository.products;

    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          freshList,
          newProducts: currentState.newProducts,
          updatedProducts: [product, ...currentState.updatedProducts],
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        freshList,
        updatedProducts: [product],
      ),
    );
  }

  Future<void> refreshProduct() async {
    final currentState = state as ReadProductSuccess;
    final freshList = productsRepository.products;
    if (currentState is HighlightedProduct) {
      emit(
        HighlightedProduct(
          freshList,
          newProducts: currentState.newProducts,
          updatedProducts: currentState.updatedProducts,
        ),
      );
      return;
    }
    emit(
      HighlightedProduct(
        freshList,
      ),
    );
  }
}
