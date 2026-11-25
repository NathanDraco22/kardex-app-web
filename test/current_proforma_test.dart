import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeOrdersRepository with ReactiveRepository<OrderInDb> implements OrdersRepository {
  OrderQueryParams? lastQueryParams;

  @override
  Future<ListResponse<OrderInDb>> getPaginatedOrders({
    required OrderQueryParams queryParams,
  }) async {
    lastQueryParams = queryParams;
    return ListResponse<OrderInDb>(count: 0, data: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

OrderInDb _buildOrder({
  required String id,
  String branchId = 'branch-1',
  String clientId = 'client-1',
  String creatorId = 'user-seller-1',
  OrderStatus status = OrderStatus.draft,
  int total = 1000,
}) {
  return OrderInDb(
    id: id,
    branchId: branchId,
    clientId: clientId,
    clientInfo: ClientInfo(name: 'Cliente Demo', group: ''),
    docNumber: 'COT-$id',
    saleItems: const [],
    status: status,
    paymentType: PaymentType.cash,
    totalCost: 500,
    total: total,
    createdAt: DateTime.now(),
    createdBy: UserInfo(id: creatorId, name: 'Vendedor Demo'),
  );
}

void main() {
  group('ReadProformaCubit - filtro por creador y reactividad', () {
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
      repo.disposeReactiveRepo();
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
      repo.disposeReactiveRepo();
    });

    test('reacciona a eventos del repositorio marcando nuevos y removiendo no-draft sin recargar', () async {
      final repo = _FakeOrdersRepository();
      final cubit = ReadProformaCubit(
        ordersRepository: repo,
        defaultCreatorId: 'user-seller-1',
      );

      await cubit.loadPaginatedOrders('branch-1');

      final ownQuote = _buildOrder(id: 'o1', creatorId: 'user-seller-1');
      final otherSellerQuote = _buildOrder(id: 'o2', creatorId: 'user-other');

      repo.notifyItemCreated(ownQuote);
      repo.notifyItemCreated(otherSellerQuote);
      await Future<void>.delayed(Duration.zero);

      var state = cubit.state as ReadProformaSuccess;
      expect(state.orders.map((e) => e.id).toList(), ['o1']);
      expect(state.newOrderIds, contains('o1'));
      expect(state.updatedOrderIds, isEmpty);

      final editedOwnQuote = ownQuote.copyWith(total: 1500);
      repo.notifyItemUpdated(editedOwnQuote);
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadProformaSuccess;
      expect(state.orders.first.total, 1500);
      expect(state.newOrderIds, isNot(contains('o1')));
      expect(state.updatedOrderIds, contains('o1'));

      final convertedQuote = editedOwnQuote.copyWith(status: OrderStatus.completed);
      repo.notifyItemUpdated(convertedQuote);
      await Future<void>.delayed(Duration.zero);

      state = cubit.state as ReadProformaSuccess;
      expect(state.orders, isEmpty);

      await cubit.close();
      repo.disposeReactiveRepo();
    });
  });
}
