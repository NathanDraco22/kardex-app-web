part of 'read_daily_product_in_orders_cubit.dart';

sealed class ReadDailyProductInOrdersState {}

final class ReadDailyProductInOrdersInitial extends ReadDailyProductInOrdersState {}

final class ReadDailyProductInOrdersLoading extends ReadDailyProductInOrdersState {}

class ReadDailyProductInOrdersSuccess extends ReadDailyProductInOrdersState {
  final List<ProductSalesTotal> productTotals;
  final int totalAmount;

  ReadDailyProductInOrdersSuccess(this.productTotals, this.totalAmount);
}

final class ReadDailyProductInOrdersError extends ReadDailyProductInOrdersState {
  final String message;
  ReadDailyProductInOrdersError(this.message);
}
