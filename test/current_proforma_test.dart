import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeOrdersRepository implements OrdersRepository {
  OrderQueryParams? lastQueryParams;

  @override
  Future<ListResponse<OrderInDb>> getPaginatedOrders({
    OrderQueryParams? queryParams,
    bool forceRefresh = false,
  }) async {
    lastQueryParams = queryParams;
    return ListResponse<OrderInDb>(count: 0, data: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReadProformaCubit - filtro por creador (Vendedor / Pre-Venta)', () {
    test('mantiene defaultCreatorId al inicializar, filtrar y limpiar filtros', () async {
      final repo = _FakeOrdersRepository();
      final cubit = ReadProformaCubit(
        ordersRepository: repo,
        defaultCreatorId: 'user-seller-1',
      );

      await cubit.loadPaginatedOrders('branch-1');
      expect(repo.lastQueryParams?.createdBy, 'user-seller-1');
      expect(repo.lastQueryParams?.status, OrderStatus.draft);

      await cubit.setFilterParams(clientId: 'client-1', createdBy: 'other-user');
      await cubit.loadPaginatedOrders('branch-1');
      expect(repo.lastQueryParams?.clientId, 'client-1');
      expect(repo.lastQueryParams?.createdBy, 'user-seller-1');

      await cubit.clearFilterParams();
      await cubit.loadPaginatedOrders('branch-1');
      expect(repo.lastQueryParams?.clientId, isNull);
      expect(repo.lastQueryParams?.createdBy, 'user-seller-1');

      await cubit.close();
    });

    test('permite cambiar y limpiar createdBy cuando defaultCreatorId es null', () async {
      final repo = _FakeOrdersRepository();
      final cubit = ReadProformaCubit(
        ordersRepository: repo,
        defaultCreatorId: null,
      );

      await cubit.setFilterParams(createdBy: 'user-2');
      await cubit.loadPaginatedOrders('branch-1');
      expect(repo.lastQueryParams?.createdBy, 'user-2');

      await cubit.clearFilterParams();
      await cubit.loadPaginatedOrders('branch-1');
      expect(repo.lastQueryParams?.createdBy, isNull);

      await cubit.close();
    });
  });
}
