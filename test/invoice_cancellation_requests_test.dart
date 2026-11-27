import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  @override
  AppSettingModel? get currentAppSettings => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBranchesRepository implements BranchesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServinRepository implements ServinRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeClientGroupsRepository implements ClientGroupsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthCubit _createTestAuthCubit() {
  return AuthCubit(
    authRepository: _FakeAuthRepository(),
    branchesRepository: _FakeBranchesRepository(),
    servinRepository: _FakeServinRepository(),
    clientGroupRepository: _FakeClientGroupsRepository(),
  );
}

Authenticated _buildAuthenticated({
  String userId = 'user-1',
  List<String> access = const ['commercial'],
}) {
  final branch = BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000000',
    address: 'Managua',
    email: 'test@example.com',
    phone: '88888888',
    createdAt: DateTime(2026),
  );

  return Authenticated(
    LoginResponse(
      accessToken: 'token',
      user: UserInDbWithRole(
        id: userId,
        username: userId,
        password: '',
        role: 'Tester',
        branches: const ['branch-1'],
        createdAt: DateTime(2026),
        userRole: UserRole(
          name: 'Tester',
          access: access,
        ),
      ),
    ),
    branch,
    [branch],
    Servin(
      name: 'Test Servin',
      nickname: 'test',
      url: 'https://example.com',
      isActive: true,
    ),
  );
}

void main() {
  tearDown(() async {
    InvoiceRounding.configureEnabledResolver(null);
    await getIt.reset();
  });

  test('InvoiceCancellationRequestInDb y InvoiceInDb serializan campos de anulación', () {
    final reqJson = {
      'id': 'req-1',
      'docNumber': '0001',
      'branchId': 'b-1',
      'invoiceId': 'inv-1',
      'invoiceDocNumber': 'F-0001',
      'invoiceTotal': 1500,
      'invoicePaymentType': 'cash',
      'invoiceStatus': 'paid',
      'invoiceShiftId': 'shift-1',
      'clientId': 'c-1',
      'clientInfo': {'name': 'Cliente General'},
      'reason': 'Error de digitación',
      'requestedBy': {'id': 'u-1', 'name': 'Cajero'},
      'status': 'pending',
      'createdAt': 1700000000000,
    };

    final req = InvoiceCancellationRequestInDb.fromJson(reqJson);
    expect(req.status, InvoiceCancellationRequestStatus.pending);
    expect(req.invoiceDocNumber, 'F-0001');
    expect(req.invoiceShiftId, 'shift-1');

    final inv = InvoiceInDb.fromJson({
      'id': 'inv-1',
      'branchId': 'b-1',
      'clientId': 'c-1',
      'clientInfo': {'name': 'Cliente General'},
      'docNumber': 'F-0001',
      'saleItems': [],
      'amountPaid': 1500,
      'status': 'cancelled',
      'paymentType': 'cash',
      'bankReference': '',
      'totalCost': 500,
      'total': 1500,
      'createdBy': {'id': 'u-1', 'name': 'Cajero'},
      'createdAt': 1700000000000,
      'cancelledAt': 1700000005000,
      'cancelledBy': {'id': 'u-2', 'name': 'Supervisor'},
      'cancellationReason': 'Error de digitación',
      'cancellationRequestId': 'req-1',
    });

    expect(inv.isCancelled, isTrue);
    expect(inv.cancelledBy?.name, 'Supervisor');
    expect(inv.cancellationReason, 'Error de digitación');
  });

  test('ShiftInDb y ShiftArqueoTotals parsean campos de facturas anuladas', () {
    final shift = ShiftInDb.fromJson({
      'id': 's-1',
      'branchId': 'b-1',
      'openedBy': {'id': 'u-1', 'name': 'Cajero'},
      'openedAt': 1700000000000,
      'createdAt': 1700000000000,
      'cancelledInvoiceCashTotal': 1200,
      'cancelledInvoiceCreditTotal': 800,
      'cancelledInvoiceTotal': 2000,
      'cancelledInvoiceCount': 2,
    });

    expect(shift.cancelledInvoiceCashTotal, 1200);
    expect(shift.cancelledInvoiceCreditTotal, 800);
    expect(shift.cancelledInvoiceTotal, 2000);
    expect(shift.cancelledInvoiceCount, 2);

    final totals = ShiftArqueoTotals.fromJson({
      'cancelledInvoiceCashSalesTotal': 1200,
      'cancelledInvoiceCreditTotal': 800,
      'cancelledInvoiceTotal': 2000,
      'cancelledInvoiceCount': 2,
    });
    expect(totals.cancelledInvoiceCount, 2);
    expect(totals.cancelledInvoiceTotal, 2000);
  });

  testWidgets('Gate con approveInvoiceCancellation oculta botones para Cajero y los muestra para Supervisor', (tester) async {
    final authCubit = _createTestAuthCubit();
    getIt.registerSingleton<AuthCubit>(authCubit);

    authCubit.emit(_buildAuthenticated(access: const ['commercial', 'invoiceHistory']));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Gate(
            filters: [
              RolePermissionGateFilter(
                permissions: [CommercialSubModules.approveInvoiceCancellation],
              ),
            ],
            child: Text('Aprobar'),
          ),
        ),
      ),
    );
    expect(find.text('Aprobar'), findsNothing);

    authCubit.emit(
      _buildAuthenticated(
        access: [
          'commercial',
          CommercialSubModules.approveInvoiceCancellation.name,
        ],
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Gate(
            filters: [
              RolePermissionGateFilter(
                permissions: [CommercialSubModules.approveInvoiceCancellation],
              ),
            ],
            child: Text('Aprobar'),
          ),
        ),
      ),
    );
    expect(find.text('Aprobar'), findsOneWidget);
  });

  test('AppSettingModel y ReceiptInDb soportan banderas de anulación por defecto en false', () {
    const settings = AppSettingModel(id: 'Default', createdAt: 0);
    expect(settings.useInvoiceCancellations, isFalse);
    expect(settings.useReceiptCancellations, isFalse);
    expect(settings.allowCancellationsOutsideShift, isFalse);

    final enabledSettings = AppSettingModel.fromJson({
      'id': 'Default',
      'createdAt': 0,
      'allowCancellationsOutsideShift': true,
    });
    expect(enabledSettings.allowCancellationsOutsideShift, isTrue);
    expect(
      const UpdateAppSetting(allowCancellationsOutsideShift: true).toJson(),
      {'allowCancellationsOutsideShift': true},
    );

    final receipt = ReceiptInDb.fromJson({
      'id': 'rec-1',
      'branchId': 'b-1',
      'clientId': 'c-1',
      'clientInfo': {'name': 'Cliente'},
      'docNumber': 'R-0001',
      'appliedInvoices': [],
      'appliedDevolutions': [],
      'paymentMethod': 'cash',
      'total': 1000,
      'createdAt': 1700000000000,
      'createdBy': {'id': 'u-1', 'name': 'Cajero'},
      'isDeleted': true,
      'cancelledAt': 1700000005000,
      'cancelledBy': {'id': 'u-2', 'name': 'Supervisor'},
      'cancellationReason': 'Monto errado',
    });
    expect(receipt.isCancelled, isTrue);
    expect(receipt.cancellationReason, 'Monto errado');
  });

  testWidgets('InvoiceCancellationsGateFilter y ReceiptCancellationsGateFilter ocultan por defecto y muestran al activarse', (tester) async {
    final settingsCubit = AppSettingsCubit(_FakeAppSettingsRepository());
    getIt.registerSingleton<AppSettingsCubit>(settingsCubit);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Gate(
                filters: [InvoiceCancellationsGateFilter()],
                child: Text('AnularFactura'),
              ),
              Gate(
                filters: [ReceiptCancellationsGateFilter()],
                child: Text('AnularRecibo'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('AnularFactura'), findsNothing);
    expect(find.text('AnularRecibo'), findsNothing);

    settingsCubit.emit(
      AppSettingsLoaded(
        const AppSettingModel(
          id: 'Default',
          createdAt: 0,
          useInvoiceCancellations: true,
          useReceiptCancellations: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('AnularFactura'), findsOneWidget);
    expect(find.text('AnularRecibo'), findsOneWidget);
  });
}
