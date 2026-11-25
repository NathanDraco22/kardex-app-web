import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/devolutions/cubit/read_devolutions_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/devolutions/web/devolutions_screen_web.dart';
import 'package:kardex_app_front/src/modules/commercial/devolutions/web/devolutions_selection_screen.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(AuthInitial());

  @override
  String get currentBranchId => 'b-1';

  @override
  UserInDbWithRole? get user => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoicesDataSource implements InvoicesDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceDevolutionsDataSource implements InvoiceDevolutionsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoicesRepository extends InvoicesRepository {
  _FakeInvoicesRepository(this.invoiceJson, this.devolutionsJson)
      : super(_FakeInvoicesDataSource(), _FakeInvoiceDevolutionsDataSource());

  final Map<String, dynamic> invoiceJson;
  final List<Map<String, dynamic>> devolutionsJson;
  String? lastDevolutionInvoiceId;

  @override
  Future<ListResponse<InvoiceInDb>> getAllInvoices(InvoiceQueryParams params) async {
    return ListResponse<InvoiceInDb>.fromJson(
      {
        'count': 1,
        'data': [invoiceJson],
      },
      InvoiceInDb.fromJson,
    );
  }

  @override
  Future<InvoiceTotals> getTotalFromInvoices(InvoiceQueryParams params) async {
    return InvoiceTotals.fromJson({
      'total': invoiceJson['total'],
      'totalCost': 5000,
      'totalDiscount': 0,
      'totalPaid': invoiceJson['amountPaid'],
    });
  }

  @override
  Future<InvoiceDevolutionResponse> getInvoiceDevolutionById(String invoiceId) async {
    lastDevolutionInvoiceId = invoiceId;
    return InvoiceDevolutionResponse.fromJson({
      'invoice': invoiceJson,
      'devolutions': devolutionsJson,
    });
  }
}

Map<String, dynamic> _invoiceJson() {
  final now = DateTime(2026, 11, 24, 14, 30).millisecondsSinceEpoch;
  return {
    'id': 'inv-1',
    'branchId': 'b-1',
    'clientId': 'c-1',
    'clientInfo': {
      'name': 'Cliente Preferencial',
      'group': '',
      'location': 'Managua',
      'address': 'Calle Central 123',
    },
    'docNumber': 'FAC-0042',
    'paymentType': 'transfer',
    'bankReference': 'REF-999',
    'status': 'paid',
    'description': 'Entrega en recepción',
    'saleItems': [
      {
        'product': {
          'id': 'prod-1',
          'code': 'SKU-01',
          'name': 'Producto Uno',
          'brandName': 'Marca A',
          'unitName': 'Unidad',
        },
        'selectedPrice': 1,
        'quantity': 2,
        'price': 5000,
        'cost': 3000,
        'subTotal': 10000,
        'total': 10000,
        'discount': 0,
        'unitName': 'Unidad',
        'conversionFactor': 1,
        'priceUnitFactor': 1,
      },
      {
        'product': {
          'id': 'prod-2',
          'code': 'SKU-02',
          'name': 'Producto Dos',
          'brandName': 'Marca B',
          'unitName': 'Caja',
        },
        'selectedPrice': 1,
        'quantity': 1,
        'price': 2500,
        'cost': 1500,
        'subTotal': 2500,
        'total': 2500,
        'discount': 0,
        'unitName': 'Caja',
        'conversionFactor': 1,
        'priceUnitFactor': 1,
      },
    ],
    'totalCost': 7500,
    'total': 12500,
    'amountPaid': 12500,
    'createdAt': now,
    'createdBy': {'id': 'u-1', 'name': 'Vendedor Demo'},
  };
}

Map<String, dynamic> _priorDevolutionJson() {
  final now = DateTime(2026, 11, 24, 15, 0).millisecondsSinceEpoch;
  return {
    'id': 'dev-1',
    'branchId': 'b-1',
    'clientId': 'c-1',
    'clientInfo': {'name': 'Cliente Preferencial', 'group': ''},
    'docNumber': 'DEV-001',
    'originalInvoiceId': 'inv-1',
    'originalInvoiceDocNumber': 'FAC-0042',
    'returnedItems': [
      (_invoiceJson()['saleItems'] as List).last,
    ],
    'description': 'Empaque dañado',
    'status': 'confirmed',
    'totalCost': 1500,
    'total': 2500,
    'createdAt': now,
    'createdBy': {'id': 'u-1', 'name': 'Vendedor Demo'},
  };
}

void main() {
  testWidgets(
    'DevolutionsSelectionScreen muestra detalles completos, botón Ver Factura y total seleccionado en vivo',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      getIt.registerSingleton<AuthCubit>(_FakeAuthCubit());
      addTearDown(() => getIt.unregister<AuthCubit>());

      final invoice = InvoiceInDb.fromJson(_invoiceJson());
      final priorDevolution = DevolutionInDb.fromJson(_priorDevolutionJson());

      await tester.pumpWidget(
        MaterialApp(
          home: DevolutionsSelectionScreen(
            invoice: invoice,
            devolutions: [priorDevolution],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ver Factura'), findsOneWidget);
      expect(find.text('Factura No. FAC-0042'), findsOneWidget);
      expect(find.text('Pagada'), findsOneWidget);
      expect(find.text('Transferencia - Ref: REF-999'), findsOneWidget);
      expect(find.text('c-1 - Cliente Preferencial'), findsOneWidget);
      expect(find.text('Vendedor Demo'), findsOneWidget);
      expect(find.text('Observación: Entrega en recepción'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Total Factura'), findsOneWidget);
      expect(find.text('Pagado'), findsOneWidget);
      expect(find.textContaining('1 devolución previa'), findsOneWidget);

      expect(find.text('Ya devuelto'), findsOneWidget);
      expect(find.text('Cód: SKU-01'), findsOneWidget);
      expect(find.text('0 productos seleccionados'), findsOneWidget);

      await tester.tap(find.text('Producto Uno'));
      await tester.pumpAndSettle();

      expect(find.text('1 producto seleccionado'), findsOneWidget);
      expect(find.text('Limpiar selección'), findsOneWidget);
    },
  );

  testWidgets(
    'DevolutionsScreenWeb no muestra botón Devolver y navega a DevolutionsSelectionScreen al tocar la fila',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      getIt.registerSingleton<AuthCubit>(_FakeAuthCubit());
      addTearDown(() => getIt.unregister<AuthCubit>());

      final repo = _FakeInvoicesRepository(_invoiceJson(), [_priorDevolutionJson()]);
      final cubit = ReadDevolutionsCubit(invoicesRepository: repo);
      await cubit.loadDailyInvoices('b-1');

      await tester.pumpWidget(
        RepositoryProvider<InvoicesRepository>.value(
          value: repo,
          child: BlocProvider<ReadDevolutionsCubit>.value(
            value: cubit,
            child: const MaterialApp(
              home: DevolutionsScreenWeb(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acciones'), findsNothing);
      expect(find.text('Devolver'), findsNothing);
      expect(find.text('#FAC-0042'), findsOneWidget);

      await tester.tap(find.text('#FAC-0042'));
      await tester.pumpAndSettle();

      expect(repo.lastDevolutionInvoiceId, 'inv-1');
      expect(find.byType(DevolutionsSelectionScreen), findsOneWidget);
      expect(find.text('Ver Factura'), findsOneWidget);
    },
  );
}
