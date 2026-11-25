import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/cubits/daily_client_invoices/read_daily_client_invoices_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_dropdown_selector.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeInvoicesDataSource implements InvoicesDataSource {
  Map<String, String>? lastInvoicesParams;
  Map<String, String>? lastTotalsParams;
  int listLengthToReturn = 0;

  @override
  Future<Map<String, dynamic>> getAllInvoices(Map<String, String> queryParams) async {
    lastInvoicesParams = queryParams;
    return {
      'count': listLengthToReturn,
      'data': List.generate(listLengthToReturn, (i) => _dummyInvoiceJson('inv-$i')),
    };
  }

  @override
  Future<Map<String, dynamic>> getTotalFromClientInvoices(Map<String, String> queryParams) async {
    lastTotalsParams = queryParams;
    return {
      'total': 15000,
      'totalCost': 9000,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceDevolutionsDataSource implements InvoiceDevolutionsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _dummyInvoiceJson(String id) => {
      'id': id,
      'docNumber': 'F-001',
      'clientId': kSaleClientId,
      'branchId': 'branch-1',
      'clientInfo': {'id': kSaleClientId, 'name': 'Cliente General'},
      'branchInfo': {'id': 'branch-1', 'name': 'Principal'},
      'createdBy': {'id': 'u-1', 'name': 'Admin'},
      'saleItems': <Map<String, dynamic>>[],
      'totalCost': 1000,
      'subTotal': 1500,
      'totalDiscount': 0,
      'totalTax': 0,
      'total': 1500,
      'amountPaid': 1500,
      'paymentType': 'cash',
      'status': 'paid',
      'createdAt': 1700000000000,
      'paidAt': 1700000000000,
    };

void main() {
  group('ReadDailyClientInvoicesCubit - filtro de cliente', () {
    test('envía clientId null (Todos), kSaleClientId (Sin cliente) o ID concreto y lo conserva en nextPage', () async {
      final invoicesDs = _FakeInvoicesDataSource();
      final repo = InvoicesRepository(invoicesDs, _FakeInvoiceDevolutionsDataSource());
      final cubit = ReadDailyClientInvoicesCubit(invoicesRepository: repo);

      // 1. Todos los clientes (por defecto)
      await cubit.loadPaidInvoices('branch-1');
      expect(cubit.state, isA<ReadDailyClientInvoicesSuccess>());
      expect(invoicesDs.lastInvoicesParams?.containsKey('clientId'), isFalse);
      expect(invoicesDs.lastTotalsParams?.containsKey('clientId'), isFalse);

      // 2. Sin cliente / Venta libre
      cubit.clientId = kSaleClientId;
      await cubit.loadPaidInvoices('branch-1');
      expect(invoicesDs.lastInvoicesParams?['clientId'], kSaleClientId);
      expect(invoicesDs.lastTotalsParams?['clientId'], kSaleClientId);

      // 3. Cliente concreto + paginación nextPage
      invoicesDs.listLengthToReturn = 1000;
      cubit.clientId = 'client-99';
      await cubit.loadPaidInvoices('branch-1');
      expect(invoicesDs.lastInvoicesParams?['clientId'], 'client-99');
      expect(cubit.isLastPage, isFalse);

      invoicesDs.listLengthToReturn = 2;
      await cubit.nextPage('branch-1');
      expect(invoicesDs.lastInvoicesParams?['clientId'], 'client-99');

      // 4. Limpiar filtros restablece a Todos
      cubit.clearFilters('branch-1');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.clientId, isNull);
      expect(invoicesDs.lastInvoicesParams?.containsKey('clientId'), isFalse);
    });
  });

  group('ClientDropdownSelector con allowNoClient', () {
    testWidgets('muestra Todos, Sin cliente y permite seleccionar desde el diálogo y limpiar', (tester) async {
      String? lastId = kSaleClientId;
      ClientInDb? lastClient;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ClientDropdownSelector(
                  allowNoClient: true,
                  selectedClient: lastClient,
                  selectedClientId: lastId,
                  onChanged: (c) => setState(() => lastClient = c),
                  onIdChanged: (id) => setState(() => lastId = id),
                );
              },
            ),
          ),
        ),
      );

      // Inicia mostrando "Sin cliente (Venta libre)"
      expect(find.text('Sin cliente (Venta libre)'), findsOneWidget);
      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);

      // Al tocar la X limpia a "Todos los Clientes"
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(lastId, isNull);
      expect(find.text('Todos los Clientes'), findsOneWidget);

      // Al tocar el selector abre el diálogo con accesos rápidos
      await tester.tap(find.text('Todos los Clientes'));
      await tester.pumpAndSettle();
      expect(find.text('Todos los Clientes'), findsWidgets);
      expect(find.text('Sin cliente (Venta libre)'), findsOneWidget);

      // Seleccionar "Sin cliente (Venta libre)"
      await tester.tap(find.text('Sin cliente (Venta libre)'));
      await tester.pumpAndSettle();
      expect(lastId, kSaleClientId);
      expect(lastClient, isNull);
      expect(find.text('Sin cliente (Venta libre)'), findsOneWidget);
    });
  });
}
