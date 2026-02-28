part of 'read_daily_product_sales_cubit.dart';

sealed class ReadDailyProductSalesState {}

final class ReadDailyProductSalesInitial extends ReadDailyProductSalesState {}

final class ReadDailyProductSalesLoading extends ReadDailyProductSalesState {}

class ReadDailyProductSalesSuccess extends ReadDailyProductSalesState {
  final List<ProductSalesTotal> productTotals;
  final int totalAmount;

  ReadDailyProductSalesSuccess(this.productTotals, this.totalAmount);
}

final class ReadDailyProductSalesError extends ReadDailyProductSalesState {
  final String message;
  ReadDailyProductSalesError(this.message);
}
