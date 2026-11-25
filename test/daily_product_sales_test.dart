import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_sales/cubit/read_daily_product_sales_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeInvoicesDataSource implements InvoicesDataSource {
  Map<String, String>? lastProductSalesParams;
  List<Map<String, dynamic>> nextResults = [];

  @override
  Future<Map<String, dynamic>> getAllProductSales(Map<String, String> queryParams) async {
    lastProductSalesParams = queryParams;
    return {
      'count': nextResults.length,
      'data': nextResults,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceDevolutionsDataSource implements InvoiceDevolutionsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReadDailyProductSalesCubit', () {
    test('soporta rango de fechas, filtro de cliente (Todos / Sin cliente / específico) y limpieza', () async {
      final ds = _FakeInvoicesDataSource()
        ..nextResults = [
          {
            'productId': 'prod-1',
            'productName': 'Producto Demo',
            'totalQuantity': 4,
            'totalBonQuantity': 1,
            'total': 7500,
          },
        ];
      final repo = InvoicesRepository(ds, _FakeInvoiceDevolutionsDataSource());
      final cubit = ReadDailyProductSalesCubit(invoicesRepository: repo);

      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 11, 10);

      // 1. Todos los clientes + rango de fechas + usuario
      await cubit.loadDailyProductSales(
        branchId: 'branch-1',
        startDate: start,
        endDate: end,
        userCreatorId: 'user-3',
      );
      expect(cubit.state, isA<ReadDailyProductSalesSuccess>());
      expect((cubit.state as ReadDailyProductSalesSuccess).totalAmount, 7500);
      expect(ds.lastProductSalesParams?['branchId'], 'branch-1');
      expect(ds.lastProductSalesParams?['createdBy'], 'user-3');
      expect(ds.lastProductSalesParams?.containsKey('clientId'), isFalse);
      expect(ds.lastProductSalesParams?['startDate'], start.millisecondsSinceEpoch.toString());
      expect(
        ds.lastProductSalesParams?['endDate'],
        end.add(const Duration(days: 1)).millisecondsSinceEpoch.toString(),
      );

      // 2. Sin cliente (Venta libre)
      await cubit.loadDailyProductSales(
        branchId: 'branch-1',
        clientId: kSaleClientId,
      );
      expect(ds.lastProductSalesParams?['clientId'], kSaleClientId);

      // 3. Cliente concreto
      await cubit.loadDailyProductSales(
        branchId: 'branch-1',
        clientId: 'client-55',
      );
      expect(ds.lastProductSalesParams?['clientId'], 'client-55');

      // 4. Limpiar filtros restablece cliente y usuario
      cubit.clearFilters('branch-1');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.clientId, isNull);
      expect(cubit.userCreatorId, isNull);
      expect(ds.lastProductSalesParams?.containsKey('clientId'), isFalse);
      expect(ds.lastProductSalesParams?.containsKey('createdBy'), isFalse);
    });

    test('blinda defaultCreatorId para Vendedor y Pre-Venta incluso al limpiar', () async {
      final ds = _FakeInvoicesDataSource();
      final repo = InvoicesRepository(ds, _FakeInvoiceDevolutionsDataSource());
      final cubit = ReadDailyProductSalesCubit(
        invoicesRepository: repo,
        defaultCreatorId: 'seller-9',
      );

      await cubit.loadDailyProductSales(
        branchId: 'branch-1',
        userCreatorId: 'other-user',
        clientId: kSaleClientId,
      );

      expect(cubit.userCreatorId, 'seller-9');
      expect(ds.lastProductSalesParams?['createdBy'], 'seller-9');
      expect(ds.lastProductSalesParams?['clientId'], kSaleClientId);

      cubit.clearFilters('branch-1');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.userCreatorId, 'seller-9');
      expect(cubit.clientId, isNull);
      expect(ds.lastProductSalesParams?['createdBy'], 'seller-9');
    });
  });
}
