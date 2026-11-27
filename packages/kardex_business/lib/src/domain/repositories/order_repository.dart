import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/models.dart';
import 'package:kardex_business/src/domain/query_params/order_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/domain/responses/order_to_invoice_response.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class OrdersRepository with ReactiveRepository<OrderInDb> {
  final OrdersDataSource ordersDataSource;

  OrdersRepository(this.ordersDataSource);

  Future<OrderInDb> createOrder(CreateOrder createOrder) async {
    final result = await ordersDataSource.createOrder(createOrder.toJson());
    final created = OrderInDb.fromJson(result);
    notifyItemCreated(created);
    return created;
  }

  Future<ListResponse<OrderInDb>> getPaginatedOrders({
    required OrderQueryParams queryParams,
  }) async {
    final results = await ordersDataSource.getPaginatedOrders(
      queryParams: queryParams.toQueryParameters(),
    );
    final response = ListResponse<OrderInDb>.fromJson(
      results,
      OrderInDb.fromJson,
    );
    return response;
  }

  Future<List<ProductSalesTotal>> getProductsInOrders({
    required OrderQueryParams queryParams,
  }) async {
    final results = await ordersDataSource.getProductsInOrders(
      queryParams: queryParams.toQueryParameters(),
    );
    final response = ListResponse<ProductSalesTotal>.fromJson(
      results,
      ProductSalesTotal.fromJson,
    );
    return response.data;
  }

  Future<List<ProductStockDemand>> productVSDemand({
    required OrderQueryParams queryParams,
  }) async {
    final results = await ordersDataSource.productVSDemand(
      queryParams: queryParams.toQueryParameters(),
    );
    final response = ListResponse<ProductStockDemand>.fromJson(
      results,
      ProductStockDemand.fromJson,
    );
    return response.data;
  }

  Future<OrderInDb?> getOrderById(String orderId) async {
    final result = await ordersDataSource.getOrderById(orderId);
    if (result == null) return null;
    return OrderInDb.fromJson(result);
  }

  Future<OrderInDb?> updateOrderById(
    String orderId,
    UpdateOrder order,
  ) async {
    final result = await ordersDataSource.updateOrderById(orderId, order.toJson());
    if (result == null) return null;
    final updated = OrderInDb.fromJson(result);
    notifyItemUpdated(updated);
    return updated;
  }

  Future<OrderToInvoiceResponse?> convertOrderToInvoice(
    String orderId, {
    String? shiftId,
  }) async {
    final result = await ordersDataSource.convertOrderToInvoice(
      orderId,
      shiftId: shiftId,
    );
    if (result == null) return null;
    final response = OrderToInvoiceResponse.fromJson(result);
    notifyItemUpdated(response.order);
    return response;
  }

  Future<OrderInDb?> cancelOrderById(String orderId) async {
    final result = await ordersDataSource.cancelOrderById(orderId);
    if (result == null) return null;
    final cancelled = OrderInDb.fromJson(result);
    notifyItemUpdated(cancelled);
    return cancelled;
  }

  Future<OrderInDb> deleteOrderDraft(String orderId) async {
    final result = await ordersDataSource.deleteOrderDraft(orderId);
    final deleted = OrderInDb.fromJson(result);
    notifyItemDeleted(deleted);
    return deleted;
  }
}
