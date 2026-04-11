part of 'read_product_stock_demand_cubit.dart';

abstract class ReadProductStockDemandState {}

class ReadProductStockDemandInitial extends ReadProductStockDemandState {}

class ReadProductStockDemandLoading extends ReadProductStockDemandState {}

class ReadProductStockDemandSuccess extends ReadProductStockDemandState {
  final List<ProductStockDemand> results;

  ReadProductStockDemandSuccess(this.results);
}

class ReadProductStockDemandError extends ReadProductStockDemandState {
  final String message;

  ReadProductStockDemandError(this.message);
}
