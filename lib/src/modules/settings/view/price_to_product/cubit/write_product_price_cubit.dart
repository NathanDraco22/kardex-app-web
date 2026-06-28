import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_product_price_state.dart';

class WriteProductPriceCubit extends Cubit<WriteProductPriceState> {
  WriteProductPriceCubit(this.productPricesRepository) : super(WriteProductPriceInitial());

  final ProductPricesRepository productPricesRepository;

  Future<void> createNewProductPrice(CreateProductPrice createProductPrice) async {
    emit(WriteProductPriceInProgress());
    try {
      final price = await productPricesRepository.createProductPrice(createProductPrice);
      emit(WriteProductPriceSuccess(price));
      emit(WriteProductPriceInitial());
    } catch (error) {
      emit(WriteProductPriceError(error.toString()));
    }
  }

  Future<void> updateProductPrice(String priceId, UpdateProductPrice updateProductPrice) async {
    emit(WriteProductPriceInProgress());
    try {
      final price = await productPricesRepository.updateProductPriceById(priceId, updateProductPrice);
      emit(WriteProductPriceSuccess(price!));
      emit(WriteProductPriceInitial());
    } catch (error) {
      emit(WriteProductPriceError(error.toString()));
    }
  }

  Future<void> deleteProductPrice(String priceId) async {
    emit(WriteProductPriceInProgress());
    try {
      final price = await productPricesRepository.deleteProductPriceById(priceId);
      emit(DeleteProductPriceSuccess(price!));
      emit(WriteProductPriceInitial());
    } catch (error) {
      emit(WriteProductPriceError(error.toString()));
    }
  }
}
