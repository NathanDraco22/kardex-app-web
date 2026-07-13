import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/uploaders/image_uploader.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_product_state.dart';

class WriteProductCubit extends Cubit<WriteProductState> {
  WriteProductCubit(this.productsRepository) : super(WriteProductInitial());

  final ProductsRepository productsRepository;

  Future<void> createNewProduct(CreateProduct createProduct, {Uint8List? imageBytes}) async {
    emit(WriteProductInProgress());
    try {
      if (imageBytes != null) {
        final url = await ImageUploader.uploadImage(
          bytes: imageBytes,
          fileName: createProduct.name,
        );
        createProduct = createProduct.copyWithNewImage(url);
      }

      final product = await productsRepository.createProduct(createProduct);
      emit(WriteProductSuccess(product));
      emit(WriteProductInitial());
    } catch (error) {
      emit(WriteProductError(error.toString()));
    }
  }

  Future<void> updateProduct(String productId, UpdateProduct updateProduct) async {
    emit(WriteProductInProgress());
    try {
      final product = await productsRepository.updateProductById(productId, updateProduct);
      emit(WriteProductSuccess(product!));
      emit(WriteProductInitial());
    } catch (error) {
      emit(WriteProductError(error.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(WriteProductInProgress());
    try {
      final product = await productsRepository.deleteProductById(productId);
      emit(DeleteProductSuccess(product!));
      emit(WriteProductInitial());
    } catch (error) {
      emit(WriteProductError(error.toString()));
    }
  }
}
