part of 'read_order_cubit.dart';

sealed class ReadOrderState {}

final class ReadOrderInitial extends ReadOrderState {}

final class ReadOrderLoading extends ReadOrderState {}

final class ReadOrderSuccess extends ReadOrderState {
  final List<OrderInDb> orders;
  final int totalCount;
  ReadOrderSuccess(this.orders, this.totalCount);
}

final class ReadOrderError extends ReadOrderState {
  final String message;
  ReadOrderError(this.message);
}
