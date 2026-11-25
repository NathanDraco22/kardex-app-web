import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeOrdersDataSource implements OrdersDataSource {
  Map<String, dynamic>? lastQueryParams;
  List<Map<String, dynamic>> nextResults = [];

  @override
  Future<Map<String, dynamic>> getPaginatedOrders({
    required Map<String, dynamic> queryParams,
  }) async {
    lastQueryParams = queryParams;
    return {'count': nextResults.length, 'data': nextResults};
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> order) async {
    final status = order['status'] as String;
    return {
      ...order,
      'id': status == OrderStatus.draft.name ? 'draft-1' : 'order-1',
      'docNumber': status == OrderStatus.draft.name ? 'COT-1' : 'ORD-001',
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
      total: (order['total'] as int?) ?? 2200,
      status: (order['status'] as String?) ?? OrderStatus.open.name,
    );
  }

  @override
  Future<Map<String, dynamic>?> cancelOrderById(String orderId) async {
    return _orderJson(
      id: orderId,
      total: 2200,
      status: OrderStatus.cancelled.name,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _orderJson({
  required String id,
  String branchId = 'branch-1',
  String clientId = 'client-1',
  String clientName = 'Cliente Demo',
  String creatorId = 'seller-1',
  String docNumber = 'ORD-001',
  String status = 'open',
  int total = 1500,
}) {
  return {
    'id': id,
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': {'name': clientName, 'group': ''},
    'docNumber': docNumber,
    'saleItems': const <Map<String, dynamic>>[],
    'description': '',
    'amountPaid': 0,
    'status': status,
    'paymentType': PaymentType.cash.name,
    'totalCost': 700,
    'total': total,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
    'createdBy': {'id': creatorId, 'name': 'Vendedor Demo'},
  };
}

void main() {
  group('ReadOrderCubit - Lobby reactivo de Órdenes de Compra', () {
    test('inicia en Abierta, blinda defaultCreatorId y reacciona sin recargar', () async {
      final ds = _FakeOrdersDataSource();
      final repo = OrdersRepository(ds);
      final cubit = ReadOrderCubit(
        ordersRepository: repo,
        branchId: 'branch-1',
        defaultCreatorId: 'seller-1',
      );

      await cubit.loadPaginatedOrders();
      expect(ds.lastQueryParams?['branchId'], 'branch-1');
      expect(ds.lastQueryParams?['status'], OrderStatus.open.name);
      expect(ds.lastQueryParams?['createdBy'], 'seller-1');

      // Crear una cotización (draft) NO debe entrar al Lobby de Órdenes
      await repo.createOrder(
        CreateOrder(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Cliente Demo', group: ''),
          saleItems: const [],
          status: OrderStatus.draft,
          paymentType: PaymentType.cash,
          totalCost: 500,
          total: 900,
          createdBy: const UserInfo(id: 'seller-1', name: 'Vendedor Demo'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      var state = cubit.state as ReadOrderSuccess;
      expect(state.orders, isEmpty);

      // Crear una orden (open) del mismo vendedor la inserta en amarillo
      await repo.createOrder(
        CreateOrder(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Cliente Demo', group: ''),
          saleItems: const [],
          status: OrderStatus.open,
          paymentType: PaymentType.cash,
          totalCost: 700,
          total: 1500,
          createdBy: const UserInfo(id: 'seller-1', name: 'Vendedor Demo'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadOrderSuccess;
      expect(state.orders.map((e) => e.id).toList(), ['order-1']);
      expect(state.totalAmount, 1500);
      expect(state.newOrderIds, contains('order-1'));
      expect(state.updatedOrderIds, isEmpty);

      // Orden de otro vendedor no debe mostrarse para Vendedor / Pre-Venta
      await repo.createOrder(
        CreateOrder(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Otro Cliente', group: ''),
          saleItems: const [],
          status: OrderStatus.open,
          paymentType: PaymentType.cash,
          totalCost: 300,
          total: 400,
          createdBy: const UserInfo(id: 'other-seller', name: 'Otro'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadOrderSuccess;
      expect(state.orders.length, 1);

      // En filtro Abierta, cancelar la orden la remueve de la lista
      await repo.cancelOrderById('order-1');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadOrderSuccess;
      expect(state.orders, isEmpty);
      expect(state.totalAmount, 0);

      // Al pasar a Todas (clearStatus: true), envía neStatus: draft y mantiene azul al editar
      ds.nextResults = [
        _orderJson(id: 'order-1', status: OrderStatus.open.name, total: 1500),
      ];
      await cubit.applyFilters(clearStatus: true, createdBy: 'other-user');
      expect(ds.lastQueryParams?.containsKey('status'), isFalse);
      expect(ds.lastQueryParams?['neStatus'], OrderStatus.draft.name);
      expect(ds.lastQueryParams?['createdBy'], 'seller-1');

      await repo.cancelOrderById('order-1');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadOrderSuccess;
      expect(state.orders.first.status, OrderStatus.cancelled);
      expect(state.updatedOrderIds, contains('order-1'));

      await cubit.close();
      repo.disposeReactiveRepo();
    });

    test('búsqueda local por folio/cliente y clearFilterParams restablece Abierta', () async {
      final ds = _FakeOrdersDataSource()
        ..nextResults = [
          _orderJson(id: 'o1', clientName: 'Distribuidora Alfa', docNumber: 'ORD-101', total: 600),
          _orderJson(id: 'o2', clientName: 'Comercial Beta', docNumber: 'ORD-102', total: 900),
        ];
      final repo = OrdersRepository(ds);
      final cubit = ReadOrderCubit(
        ordersRepository: repo,
        branchId: 'branch-1',
      );

      await cubit.loadPaginatedOrders();
      cubit.searchOrder('alfa');

      var state = cubit.state as ReadOrderSuccess;
      expect(state.orders.map((e) => e.id).toList(), ['o1']);
      expect(state.totalAmount, 600);

      cubit.searchOrder('ORD-102');
      state = cubit.state as ReadOrderSuccess;
      expect(state.orders.map((e) => e.id).toList(), ['o2']);
      expect(state.totalAmount, 900);

      await cubit.applyFilters(clearStatus: true, clientId: 'client-5');
      expect(cubit.status, isNull);
      expect(cubit.clientId, 'client-5');

      await cubit.clearFilterParams();
      expect(cubit.status, OrderStatus.open);
      expect(cubit.clientId, isNull);
      expect(cubit.searchKeyword, isEmpty);

      await cubit.close();
      repo.disposeReactiveRepo();
    });
  });
}
