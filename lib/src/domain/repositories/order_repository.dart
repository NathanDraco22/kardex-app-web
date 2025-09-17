import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class OrdersRepository {
  final OrdersDataSource ordersDataSource;

  OrdersRepository(this.ordersDataSource);

  Future<OrderInDb> createOrder(CreateOrder createOrder) async {
    final result = await ordersDataSource.createOrder(createOrder.toJson());
    return OrderInDb.fromJson(result);
  }

  Future<ListResponse<OrderInDb>> getPaginatedOrders({
    required int offset,
    String? clientId,
  }) async {
    final results = await ordersDataSource.getPaginatedOrders(
      offset: offset,
      clientId: clientId,
    );
    final response = ListResponse<OrderInDb>.fromJson(
      results,
      OrderInDb.fromJson,
    );
    return response;
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
}
