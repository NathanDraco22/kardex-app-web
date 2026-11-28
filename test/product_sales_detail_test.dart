import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/cubits/invoice_by_product/read_invoice_by_product_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

Map<String, dynamic> _saleItemJson({
  String productId = 'prod-1',
  int quantity = 1,
  int bonQuantity = 0,
  int total = 1000,
  int conversionFactor = 1,
}) {
  return {
    'product': {
      'id': productId,
      'name': 'Producto Demo',
      'unitName': 'Unidad',
      'productType': 'item',
    },
    'selectedPrice': 1,
    'quantity': quantity,
    'bonQuantity': bonQuantity,
    'cost': 500,
    'price': 1000,
    'subTotal': total,
    'total': total,
    'conversionFactor': conversionFactor,
  };
}

Map<String, dynamic> _invoiceJson({
  required String id,
  required DateTime createdAt,
  List<Map<String, dynamic>>? saleItems,
  String docNumber = '001-001',
}) {
  return {
    'id': id,
    'branchId': 'branch-1',
    'clientId': 'client-1',
    'clientInfo': {'name': 'Cliente Demo', 'group': 'General'},
    'docNumber': docNumber,
    'saleItems': saleItems ?? [_saleItemJson()],
    'status': 'paid',
    'paymentType': 'cash',
    'totalCost': 500,
    'total': 1000,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'createdBy': {'id': 'user-1', 'name': 'Usuario Demo'},
  };
}

class _FakeInvoicesDataSource implements InvoicesDataSource {
  Map<String, String>? lastInvoicesParams;
  Map<String, String>? lastSummaryParams;
  String? lastProductId;
  List<Map<String, dynamic>> nextResults = [];

  @override
  Future<Map<String, dynamic>> getInvoicesByProduct(
    String productId,
    Map<String, String> params,
  ) async {
    lastProductId = productId;
    lastInvoicesParams = params;
    return {
      'count': nextResults.length,
      'data': nextResults,
    };
  }

  @override
  Future<Map<String, dynamic>> getProductSalesSummary(
    String productId,
    Map<String, String> params,
  ) async {
    lastProductId = productId;
    lastSummaryParams = params;
    return {
      'productId': productId,
      'totalQuantity': 4,
      'totalBonQuantity': 1,
      'total': 7500,
      'invoiceCount': 2,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PagedInvoicesDataSource implements InvoicesDataSource {
  _PagedInvoicesDataSource({
    required this.firstPage,
    required this.secondPage,
  });

  final List<Map<String, dynamic>> firstPage;
  final List<Map<String, dynamic>> secondPage;

  int invoiceCalls = 0;
  bool failNextPage = false;
  Map<String, String>? lastInvoicesParams;
  Map<String, String>? lastSummaryParams;

  @override
  Future<Map<String, dynamic>> getInvoicesByProduct(
    String productId,
    Map<String, String> params,
  ) async {
    lastInvoicesParams = params;
    invoiceCalls++;

    if (invoiceCalls == 1) {
      return {'count': firstPage.length, 'data': firstPage};
    }

    if (failNextPage) {
      throw Exception('fallo de red al paginar');
    }

    return {'count': secondPage.length, 'data': secondPage};
  }

  @override
  Future<Map<String, dynamic>> getProductSalesSummary(
    String productId,
    Map<String, String> params,
  ) async {
    lastSummaryParams = params;
    final total = firstPage.length + secondPage.length;
    return {
      'productId': productId,
      'totalQuantity': total,
      'totalBonQuantity': 0,
      'total': total * 1000,
      'invoiceCount': total,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedInvoicesDataSource implements InvoicesDataSource {
  final Map<String, Completer<Map<String, dynamic>>> invoiceRequests = {};
  final Map<String, Completer<Map<String, dynamic>>> summaryRequests = {};

  @override
  Future<Map<String, dynamic>> getInvoicesByProduct(
    String productId,
    Map<String, String> params,
  ) {
    final completer = Completer<Map<String, dynamic>>();
    invoiceRequests[productId] = completer;
    return completer.future;
  }

  @override
  Future<Map<String, dynamic>> getProductSalesSummary(
    String productId,
    Map<String, String> params,
  ) {
    final completer = Completer<Map<String, dynamic>>();
    summaryRequests[productId] = completer;
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceDevolutionsDataSource implements InvoiceDevolutionsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InvoicesRepository _buildRepository(InvoicesDataSource ds) {
  return InvoicesRepository(ds, _FakeInvoiceDevolutionsDataSource());
}

Map<String, dynamic> _summaryJson(String productId, {int count = 2, int total = 7500}) {
  return {
    'productId': productId,
    'totalQuantity': 4,
    'totalBonQuantity': 1,
    'total': total,
    'invoiceCount': count,
  };
}

void main() {
  group('ReadInvoiceByProductCubit', () {
    test('soporta rango de fechas, cliente y usuario, y expone el resumen', () async {
      final ds = _FakeInvoicesDataSource();
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 11, 10);
      final expectedEnd = DateTime(2026, 11, 10, 23, 59, 59, 999);

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
        startDate: start,
        endDate: end,
        userCreatorId: 'user-3',
      );

      expect(cubit.state, isA<ReadInvoiceByProductSuccess>());

      final success = cubit.state as ReadInvoiceByProductSuccess;
      expect(success.summary.total, 7500);
      expect(success.summary.invoiceCount, 2);
      expect(success.count, 2);
      expect(success.startDate, start);
      expect(success.endDate, expectedEnd);
      expect(success.clientId, isNull);
      expect(success.userCreatorId, 'user-3');

      expect(ds.lastProductId, 'prod-1');
      expect(ds.lastInvoicesParams?['branchId'], 'branch-1');
      expect(ds.lastInvoicesParams?['createdBy'], 'user-3');
      expect(ds.lastInvoicesParams?.containsKey('clientId'), isFalse);
      expect(ds.lastInvoicesParams?['startDate'], start.millisecondsSinceEpoch.toString());
      expect(ds.lastInvoicesParams?['endDate'], expectedEnd.millisecondsSinceEpoch.toString());
      expect(ds.lastSummaryParams?['startDate'], start.millisecondsSinceEpoch.toString());
      expect(ds.lastSummaryParams?['endDate'], expectedEnd.millisecondsSinceEpoch.toString());

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
        clientId: kSaleClientId,
      );
      expect(ds.lastInvoicesParams?['clientId'], kSaleClientId);
      expect(ds.lastSummaryParams?['clientId'], kSaleClientId);
      expect((cubit.state as ReadInvoiceByProductSuccess).clientId, kSaleClientId);

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
        clientId: 'client-55',
      );
      expect(ds.lastInvoicesParams?['clientId'], 'client-55');

      cubit.clearFilters('branch-1');
      expect(cubit.state, isA<ReadInvoiceByProductInitial>());
      expect(cubit.clientId, isNull);
      expect(cubit.userCreatorId, isNull);
      expect(cubit.productId, isNull);
    });

    test('blinda defaultCreatorId para Vendedor y Pre-Venta', () async {
      final ds = _FakeInvoicesDataSource();
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
        defaultCreatorId: 'seller-9',
      );

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
        userCreatorId: 'other-user',
        clientId: kSaleClientId,
      );

      expect(cubit.userCreatorId, 'seller-9');
      expect(ds.lastInvoicesParams?['createdBy'], 'seller-9');
      expect(ds.lastInvoicesParams?['clientId'], kSaleClientId);

      cubit.clearFilters('branch-1');
      expect(cubit.userCreatorId, 'seller-9');
      expect(cubit.clientId, isNull);
      expect(cubit.productId, isNull);
    });

    test('exporta con los parámetros de la última consulta aplicada', () async {
      final ds = _FakeInvoicesDataSource();
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
        clientId: 'client-1',
      );

      cubit.clientId = 'client-2';
      final invoices = await cubit.fetchAllInvoicesForExport();

      expect(invoices, isEmpty);
      expect(ds.lastInvoicesParams?['clientId'], 'client-1');
      expect(ds.lastInvoicesParams?['offset'], '0');
      expect(ds.lastInvoicesParams?['limit'], '200');
      expect(ds.lastInvoicesParams?.containsKey('cursorDate'), isFalse);
      expect(ds.lastInvoicesParams?.containsKey('cursorId'), isFalse);
    });

    test('pagina por cursor usando la última factura cargada', () async {
      final firstPage = List.generate(50, (index) {
        return _invoiceJson(
          id: 'inv-$index',
          docNumber: '$index',
          createdAt: DateTime(2026, 11, 10).subtract(Duration(minutes: index)),
        );
      });
      final lastFirstPageInvoice = firstPage.last;
      final secondPage = [
        _invoiceJson(
          id: 'inv-50',
          docNumber: '50',
          createdAt: DateTime(2026, 11, 9),
        ),
      ];
      final ds = _PagedInvoicesDataSource(
        firstPage: firstPage,
        secondPage: secondPage,
      );
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
      );

      expect((cubit.state as ReadInvoiceByProductSuccess).invoices.length, 50);

      await cubit.nextPage();

      final success = cubit.state as ReadInvoiceByProductSuccess;
      expect(success.invoices.length, 51);
      expect(success.invoices.last.id, 'inv-50');
      expect(ds.lastInvoicesParams?['offset'], '0');
      expect(ds.lastInvoicesParams?['limit'], '50');
      expect(
        ds.lastInvoicesParams?['cursorDate'],
        lastFirstPageInvoice['createdAt'].toString(),
      );
      expect(ds.lastInvoicesParams?['cursorId'], 'inv-49');
    });

    test('mantiene la lista y permite reintentar si falla la paginación', () async {
      final firstPage = List.generate(50, (index) {
        return _invoiceJson(
          id: 'inv-$index',
          docNumber: '$index',
          createdAt: DateTime(2026, 11, 10).subtract(Duration(minutes: index)),
        );
      });
      final secondPage = [
        _invoiceJson(
          id: 'inv-50',
          docNumber: '50',
          createdAt: DateTime(2026, 11, 9),
        ),
      ];
      final ds = _PagedInvoicesDataSource(
        firstPage: firstPage,
        secondPage: secondPage,
      )..failNextPage = true;
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      await cubit.loadInvoicesByProduct(
        productId: 'prod-1',
        branchId: 'branch-1',
      );
      await cubit.nextPage();

      final errorState = cubit.state;
      expect(errorState, isA<ReadInvoiceByProductLoadMoreError>());
      expect(
        (errorState as ReadInvoiceByProductLoadMoreError).invoices.length,
        50,
      );
      expect(errorState.summary.invoiceCount, 51);

      ds.failNextPage = false;
      await cubit.nextPage();

      expect(
        (cubit.state as ReadInvoiceByProductSuccess).invoices.length,
        51,
      );
    });

    test('descarta respuestas viejas cuando cambia la consulta', () async {
      final ds = _DelayedInvoicesDataSource();
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      final loadA = cubit.loadInvoicesByProduct(
        productId: 'prod-A',
        branchId: 'branch-1',
      );
      final loadB = cubit.loadInvoicesByProduct(
        productId: 'prod-B',
        branchId: 'branch-1',
      );

      ds.summaryRequests['prod-B']!.complete(_summaryJson('prod-B', count: 1, total: 100));
      ds.invoiceRequests['prod-B']!.complete({
        'count': 1,
        'data': [
          _invoiceJson(
            id: 'inv-B',
            createdAt: DateTime(2026, 11, 10),
          ),
        ],
      });
      await loadB;

      expect((cubit.state as ReadInvoiceByProductSuccess).summary.productId, 'prod-B');
      expect((cubit.state as ReadInvoiceByProductSuccess).invoices.single.id, 'inv-B');

      ds.summaryRequests['prod-A']!.complete(_summaryJson('prod-A', count: 1, total: 200));
      ds.invoiceRequests['prod-A']!.complete({
        'count': 1,
        'data': [
          _invoiceJson(
            id: 'inv-A',
            createdAt: DateTime(2026, 11, 10),
          ),
        ],
      });
      await loadA;

      final success = cubit.state as ReadInvoiceByProductSuccess;
      expect(success.summary.productId, 'prod-B');
      expect(success.invoices.single.id, 'inv-B');
    });

    test('no emite después de cerrar el cubit', () async {
      final ds = _DelayedInvoicesDataSource();
      final cubit = ReadInvoiceByProductCubit(
        invoicesRepository: _buildRepository(ds),
      );

      final load = cubit.loadInvoicesByProduct(
        productId: 'prod-A',
        branchId: 'branch-1',
      );

      await cubit.close();

      ds.summaryRequests['prod-A']!.complete(_summaryJson('prod-A'));
      ds.invoiceRequests['prod-A']!.complete({
        'count': 1,
        'data': [
          _invoiceJson(
            id: 'inv-A',
            createdAt: DateTime(2026, 11, 10),
          ),
        ],
      });

      await load;
    });

    test('agrupa multilínea del mismo producto y usa la unidad comercial', () {
      final invoice = InvoiceInDb.fromJson(
        _invoiceJson(
          id: 'inv-multi',
          createdAt: DateTime(2026, 11, 10),
          saleItems: [
            _saleItemJson(quantity: 12, total: 1200, conversionFactor: 12),
            _saleItemJson(quantity: 12, total: 800, conversionFactor: 12),
          ],
        ),
      );

      final line = invoice.productLine('prod-1');

      expect(line.isEmpty, isFalse);
      expect(line.quantity, 24);
      expect(line.totalUnits, 24);
      expect(line.total, 2000);
      expect(line.quantityText, '2.00');
    });
  });
}
