part of 'read_sale_projection_cubit.dart';

sealed class ReadSaleProjectionState {}

final class ReadSaleProjectionInitial extends ReadSaleProjectionState {}

final class ReadSaleProjectionLoading extends ReadSaleProjectionState {}

final class ReadSaleProjectionSuccess extends ReadSaleProjectionState {
  final List<ProductStatInDbWithAccount> stats;

  ReadSaleProjectionSuccess(this.stats);
}

final class ReadSaleProjectionFailure extends ReadSaleProjectionState {
  final String message;

  ReadSaleProjectionFailure(this.message);
}
