import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_in_orders/cubit/read_daily_product_in_orders_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeOrdersDataSource implements OrdersDataSource {
  Map<String, String>? lastQueryParams;
  List<Map<String, dynamic>> nextResults = [];

  @override
  Future<Map<String, dynamic>> getProductsInOrders({
    required Map<String, String> queryParams,
  }) async {
    lastQueryParams = queryParams;
    return {'count': nextResults.length, 'data': nextResults};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReadDailyProductInOrdersCubit', () {
    test('soporta rango de fechas, selector de cliente y limpieza de filtros', () async {
      final ds = _FakeOrdersDataSource()
        ..nextResults = [
          {
            'productId': 'prod-1',
            'productName': 'Producto Demo',
            'totalQuantity': 3,
            'totalBonQuantity': 1,
            'total': 4500,
          },
        ];
      final repo = OrdersRepository(ds);
      final cubit = ReadDailyProductInOrdersCubit(ordersRepository: repo);

      final start = DateTime(2026, 11, 1, 10, 30);
      final end = DateTime(2026, 11, 15, 8, 15);

      await cubit.loadDailyProductInOrders(
        branchId: 'branch-1',
        startDate: start,
        endDate: end,
        clientId: 'client-12',
        userCreatorId: 'user-5',
      );

      expect(cubit.state, isA<ReadDailyProductInOrdersSuccess>());
      final success = cubit.state as ReadDailyProductInOrdersSuccess;
      expect(success.totalAmount, 4500);
      expect(ds.lastQueryParams?['branchId'], 'branch-1');
      expect(ds.lastQueryParams?['clientId'], 'client-12');
      expect(ds.lastQueryParams?['createdBy'], 'user-5');
      expect(ds.lastQueryParams?['neStatus'], OrderStatus.cancelled.name);
      expect(
        ds.lastQueryParams?['startDate'],
        DateTime(2026, 11, 1).millisecondsSinceEpoch.toString(),
      );
      expect(
        ds.lastQueryParams?['endDate'],
        DateTime(2026, 11, 1).endOfDay().millisecondsSinceEpoch > 0
            ? end.endOfDay().millisecondsSinceEpoch.toString()
            : null,
      );

      await cubit.loadDailyProductInOrders(
        branchId: 'branch-1',
        status: OrderStatus.completed,
      );
      expect(ds.lastQueryParams?['status'], OrderStatus.completed.name);
      expect(ds.lastQueryParams?.containsKey('neStatus'), isFalse);

      await cubit.loadDailyProductInOrders(
        branchId: 'branch-1',
        status: OrderStatus.open,
      );
      expect(ds.lastQueryParams?['status'], OrderStatus.open.name);
      expect(ds.lastQueryParams?.containsKey('neStatus'), isFalse);

      await cubit.loadDailyProductInOrders(
        branchId: 'branch-1',
        clearClient: true,
        clearUserCreator: true,
        clearStatus: true,
      );
      expect(ds.lastQueryParams?.containsKey('clientId'), isFalse);
      expect(ds.lastQueryParams?.containsKey('createdBy'), isFalse);
      expect(ds.lastQueryParams?.containsKey('status'), isFalse);
      expect(ds.lastQueryParams?['neStatus'], OrderStatus.cancelled.name);

      cubit.clearFilters('branch-1');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.clientId, isNull);
      expect(cubit.userCreatorId, isNull);
      expect(cubit.status, isNull);
    });

    test('blinda defaultCreatorId para Vendedor y Pre-Venta incluso al limpiar', () async {
      final ds = _FakeOrdersDataSource();
      final repo = OrdersRepository(ds);
      final cubit = ReadDailyProductInOrdersCubit(
        ordersRepository: repo,
        defaultCreatorId: 'seller-1',
      );

      await cubit.loadDailyProductInOrders(
        branchId: 'branch-1',
        userCreatorId: 'other-user',
        clientId: 'client-7',
      );

      expect(cubit.userCreatorId, 'seller-1');
      expect(ds.lastQueryParams?['createdBy'], 'seller-1');
      expect(ds.lastQueryParams?['clientId'], 'client-7');

      cubit.clearFilters('branch-1');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.userCreatorId, 'seller-1');
      expect(cubit.clientId, isNull);
      expect(ds.lastQueryParams?['createdBy'], 'seller-1');
    });
  });
}
