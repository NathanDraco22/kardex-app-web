import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class OrdersDataSource with HttpService {
  OrdersDataSource._();
  static final OrdersDataSource instance = OrdersDataSource._();
  factory OrdersDataSource() {
    return instance;
  }

  final _endpoint = "/orders";

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> order) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, order);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedOrders({
    required int offset,
    String? clientId,
    String? startDate,
    String? endDate,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "skip": offset.toString(),
        "limit": paginationItems.toString(),
        "clientId": ?clientId,
        "startDate": ?startDate,
        "endDate": ?endDate,
        "branchId": currentBranch,
      },
    );
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final uri = HttpTools.generateUri("$_endpoint/$orderId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateOrderById(
    String orderId,
    Map<String, dynamic> order,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$orderId");
    final res = await patchQuery(uri, body: order);
    return res;
  }

  Future<Map<String, dynamic>?> convertOrderToInvoice(String orderId) async {
    final uri = HttpTools.generateUri("$_endpoint/make-invoice/$orderId");
    final res = await postQuery(uri, {});
    return res;
  }

  Future<Map<String, dynamic>?> cancelOrderById(String orderId) async {
    final uri = HttpTools.generateUri("$_endpoint/cancel/$orderId");
    final res = await patchQuery(uri);
    return res;
  }
}
