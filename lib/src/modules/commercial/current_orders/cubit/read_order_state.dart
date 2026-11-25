part of 'read_order_cubit.dart';

sealed class ReadOrderState {}

final class ReadOrderInitial extends ReadOrderState {}

final class ReadOrderLoading extends ReadOrderState {}

final class ReadOrderSuccess extends ReadOrderState {
  final List<OrderInDb> orders;
  final int totalCount;
  final int totalAmount;
  final Set<String> newOrderIds;
  final Set<String> updatedOrderIds;

  ReadOrderSuccess(
    this.orders,
    this.totalCount, {
    this.totalAmount = 0,
    this.newOrderIds = const {},
    this.updatedOrderIds = const {},
  });
}

final class ReadOrderError extends ReadOrderState {
  final String message;
  ReadOrderError(this.message);
}
