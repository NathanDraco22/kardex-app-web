part of 'read_product_in_branch_cubit.dart';

sealed class ReadProductInBranchState {}

final class ReadProductInBranchInitial extends ReadProductInBranchState {}

final class ReadProductInBranchLoading extends ReadProductInBranchState {}

class ReadProductInBranchSuccess extends ReadProductInBranchState {
  final List<ProductInDbInBranch> products;
  final List<ProductInDbInBranch> editedProducts;
  final List<ProductInDbInBranch> newProducts;

  ReadProductInBranchSuccess({
    required this.products,
    this.editedProducts = const [],
    this.newProducts = const [],
  });
}

final class ReadProductInBranchFetchingMore extends ReadProductInBranchSuccess {
  ReadProductInBranchFetchingMore({
    required super.products,
    required super.editedProducts,
    super.newProducts,
  });
}

final class ReadProductInBranchErrorPagination extends ReadProductInBranchSuccess {
  final String message;

  ReadProductInBranchErrorPagination({
    required this.message,
    required super.products,
    required super.editedProducts,
    super.newProducts,
  });
}

final class ReadProductInBranchFailure extends ReadProductInBranchState {
  final String message;

  ReadProductInBranchFailure({required this.message});
}
