part of 'read_terminal_product_cubit.dart';

sealed class ReadTerminalProductState {}

final class ReadTerminalProductInitial extends ReadTerminalProductState {}

final class ReadTerminalProductLoading extends ReadTerminalProductState {}

class ReadTerminalProductSuccess extends ReadTerminalProductState {
  final List<ProductInDbInBranch> products;
  ReadTerminalProductSuccess(this.products);
}

final class ReadTerminalProductSearching extends ReadTerminalProductSuccess {
  ReadTerminalProductSearching(super.products);
}

final class ReadTerminalProductError extends ReadTerminalProductState {
  final String message;
  ReadTerminalProductError(this.message);
}
