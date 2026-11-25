import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/quotation_order_search/cubit/read_quotation_order_search_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeOrdersDataSource implements OrdersDataSource {
  Map<String, dynamic>? lastQueryParams;

  @override
  Future<Map<String, dynamic>> getPaginatedOrders({
    required Map<String, dynamic> queryParams,
  }) async {
    lastQueryParams = queryParams;
    return {'count': 0, 'data': <Map<String, dynamic>>[]};
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> order) async {
    return {
      ...order,
      'id': 'created-1',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<Map<String, dynamic>?> updateOrderById(
    String orderId,
    Map<String, dynamic> order,
  ) async {
    return _orderJson(
      id: orderId,
      total: (order['total'] as int?) ?? 2500,
      status: (order['status'] as String?) ?? OrderStatus.draft.name,
    );
  }

  @override
  Future<Map<String, dynamic>?> cancelOrderById(String orderId) async {
    return _orderJson(
      id: orderId,
      total: 2500,
      status: OrderStatus.cancelled.name,
    );
  }

  @override
  Future<Map<String, dynamic>> deleteOrderDraft(String orderId) async {
    return _orderJson(
      id: orderId,
      total: 2500,
      status: OrderStatus.draft.name,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _orderJson({
  required String id,
  String branchId = 'branch-1',
  String clientId = 'client-1',
  String creatorId = 'seller-1',
  String status = 'draft',
  int total = 1200,
}) {
  return {
    'id': id,
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': {'name': 'Cliente Demo', 'group': ''},
    'docNumber': 'COT-$id',
    'saleItems': const <Map<String, dynamic>>[],
    'description': '',
    'amountPaid': 0,
    'status': status,
    'paymentType': PaymentType.cash.name,
    'totalCost': 600,
    'total': total,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
    'createdBy': {'id': creatorId, 'name': 'Vendedor Demo'},
  };
}

void main() {
  group('OrdersRepository reactivo y ReadQuotationOrderSearchCubit', () {
    test('actualiza Lobby sin recargar y marca nuevos en amarillo y editados en azul', () async {
      final ds = _FakeOrdersDataSource();
      final repo = OrdersRepository(ds);
      final cubit = ReadQuotationOrderSearchCubit(
        ordersRepository: repo,
        defaultCreatorId: 'seller-1',
      );

      await cubit.loadDocuments('branch-1');
      expect(ds.lastQueryParams?['createdBy'], 'seller-1');

      await repo.createOrder(
        CreateOrder(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Cliente Demo', group: ''),
          saleItems: const [],
          status: OrderStatus.draft,
          paymentType: PaymentType.cash,
          totalCost: 600,
          total: 1200,
          createdBy: const UserInfo(id: 'seller-1', name: 'Vendedor Demo'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      var state = cubit.state as ReadQuotationOrderSearchSuccess;
      expect(state.orders.map((e) => e.id).toList(), ['created-1']);
      expect(state.totalCount, 1);
      expect(state.totalAmount, 1200);
      expect(state.newOrderIds, contains('created-1'));
      expect(state.updatedOrderIds, isEmpty);

      // Crear cotización de otro vendedor no debe aparecer para Vendedor/Pre-Venta
      await repo.createOrder(
        CreateOrder(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Otro Cliente', group: ''),
          saleItems: const [],
          status: OrderStatus.draft,
          paymentType: PaymentType.cash,
          totalCost: 300,
          total: 500,
          createdBy: const UserInfo(id: 'other-seller', name: 'Otro'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadQuotationOrderSearchSuccess;
      expect(state.orders.length, 1);

      // Editar pasa de newOrderIds (amarillo) a updatedOrderIds (azul)
      await repo.updateOrderById('created-1', UpdateOrder(total: 2500));
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadQuotationOrderSearchSuccess;
      expect(state.orders.first.total, 2500);
      expect(state.totalAmount, 2500);
      expect(state.newOrderIds, isNot(contains('created-1')));
      expect(state.updatedOrderIds, contains('created-1'));

      // Cancelar mantiene en Lobby (estado cancelado) marcado como actualizado
      await repo.cancelOrderById('created-1');
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadQuotationOrderSearchSuccess;
      expect(state.orders.first.status, OrderStatus.cancelled);
      expect(state.updatedOrderIds, contains('created-1'));

      // Eliminar borrador lo remueve del Lobby
      await repo.deleteOrderDraft('created-1');
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadQuotationOrderSearchSuccess;
      expect(state.orders, isEmpty);
      expect(state.totalCount, 0);
      expect(state.totalAmount, 0);

      await cubit.close();
      repo.disposeReactiveRepo();
    });
  });
}
