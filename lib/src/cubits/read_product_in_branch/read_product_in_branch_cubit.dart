import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/query_params/product_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_product_in_branch_state.dart';

class ReadProductInBranchCubit extends Cubit<ReadProductInBranchState> {
  ReadProductInBranchCubit({
    required this.productsRepository,
  }) : super(ReadProductInBranchInitial());

  final ProductsRepository productsRepository;

  ProductQueryParams _params = ProductQueryParams(offset: 0, limit: 50);
  bool isLastPage = false;

  Future<void> getProducts({ProductQueryParams? params}) async {
    emit(ReadProductInBranchLoading());
    _params = params ?? ProductQueryParams(offset: 0, limit: 50, branchId: _params.branchId);
    isLastPage = false;

    try {
      final products = await productsRepository.getAllProductsInBranch(_params);

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

  Future<void> getNextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadProductInBranchSuccess) return;
    if (currentState is ReadProductInBranchFetchingMore) return;

    emit(
      ReadProductInBranchFetchingMore(
        products: currentState.products,
        editedProducts: currentState.editedProducts,
      ),
    );

    try {
      final products = await productsRepository.getAllProductsInBranch(_params);

      if (products.length < _params.limit) {
        isLastPage = true;
      }

      _params = ProductQueryParams(
        offset: _params.offset + products.length,
        limit: _params.limit,
        branchId: _params.branchId,
      );

      emit(
        ReadProductInBranchSuccess(
          products: [...currentState.products, ...products],
          editedProducts: currentState.editedProducts,
        ),
      );
    } catch (e) {
      emit(
        ReadProductInBranchErrorPagination(
          message: e.toString(),
          products: currentState.products,
          editedProducts: currentState.editedProducts,
        ),
      );
    }
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
      ),
    );
  }
}
