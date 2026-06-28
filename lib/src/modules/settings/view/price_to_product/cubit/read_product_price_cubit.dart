import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_price_state.dart';

class ReadProductPriceCubit extends Cubit<ReadProductPriceState> {
  ReadProductPriceCubit(this.productPricesRepository) : super(ReadProductPriceInitial());

  final ProductPricesRepository productPricesRepository;

  Future<void> loadAllProductPrices() async {
    emit(ReadProductPriceLoading());
    try {
      final prices = await productPricesRepository.getAllProductPrices();
      emit(ReadProductPriceSuccess(prices));
    } catch (error) {
      emit(ProductPriceReadError(error.toString()));
    }
  }

  Future<void> searchProductPriceByKeyword(String keyword) async {
    final currentState = state as ReadProductPriceSuccess;

    if (keyword.isEmpty) {
      emit(ReadProductPriceSuccess(productPricesRepository.productPrices));
      return;
    }

    emit(ProductPriceReadSearching(currentState.productPrices));
    try {
      final prices = await productPricesRepository.searchProductPriceByKeyword(keyword);
      emit(ReadProductPriceSuccess(prices));
    } catch (error) {
      emit(ProductPriceReadError(error.toString()));
    }
  }

  Future<void> putProductPriceFirst(ProductPriceInDb price) async {
    final currentState = state as ReadProductPriceSuccess;
    final freshList = productPricesRepository.productPrices;
    if (currentState is HighlightedProductPrice) {
      emit(
        HighlightedProductPrice(
          freshList,
          newProductPrices: [price, ...currentState.newProductPrices],
          updatedProductPrices: currentState.updatedProductPrices,
        ),
      );
      return;
    }
    emit(
      HighlightedProductPrice(
        freshList,
        newProductPrices: [price],
      ),
    );
  }

  Future<void> markProductPriceUpdated(ProductPriceInDb price) async {
    final currentState = state as ReadProductPriceSuccess;
    final freshList = productPricesRepository.productPrices;

    if (currentState is HighlightedProductPrice) {
      emit(
        HighlightedProductPrice(
          freshList,
          newProductPrices: currentState.newProductPrices,
          updatedProductPrices: [price, ...currentState.updatedProductPrices],
        ),
      );
      return;
    }
    emit(
      HighlightedProductPrice(
        freshList,
        updatedProductPrices: [price],
      ),
    );
  }

  Future<void> refreshProductPrice() async {
    final currentState = state as ReadProductPriceSuccess;
    final freshList = productPricesRepository.productPrices;
    if (currentState is HighlightedProductPrice) {
      emit(
        HighlightedProductPrice(
          freshList,
          newProductPrices: currentState.newProductPrices,
          updatedProductPrices: currentState.updatedProductPrices,
        ),
      );
      return;
    }
    emit(
      HighlightedProductPrice(
        freshList,
      ),
    );
  }
}
