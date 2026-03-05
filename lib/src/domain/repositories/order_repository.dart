import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/query_params/order_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';
import 'package:kardex_app_front/src/domain/responses/order_to_invoice_response.dart';

class OrdersRepository {
  final OrdersDataSource ordersDataSource;

  OrdersRepository(this.ordersDataSource);

  Future<OrderInDb> createOrder(CreateOrder createOrder) async {
    final result = await ordersDataSource.createOrder(createOrder.toJson());
    return OrderInDb.fromJson(result);
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
    return OrderInDb.fromJson(result);
  }

  Future<OrderToInvoiceResponse?> convertOrderToInvoice(String orderId) async {
    final result = await ordersDataSource.convertOrderToInvoice(orderId);
    if (result == null) return null;
    final response = OrderToInvoiceResponse.fromJson(result);
    return response;
  }

  Future<OrderInDb?> cancelOrderById(String orderId) async {
    final result = await ordersDataSource.cancelOrderById(orderId);
    if (result == null) return null;
    return OrderInDb.fromJson(result);
  }

  Future<OrderInDb> deleteOrderDraft(String orderId) async {
    final result = await ordersDataSource.deleteOrderDraft(orderId);
    return OrderInDb.fromJson(result);
  }
}
