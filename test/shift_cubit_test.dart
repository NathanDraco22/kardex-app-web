import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_state.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeShiftsDataSource implements ShiftsDataSource {
  @override
  Future<Map<String, dynamic>?> getActiveShiftByUser(String userId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShiftsRepository extends ShiftsRepository {
  _FakeShiftsRepository() : super(_FakeShiftsDataSource());
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('Modelos de Turnos y Caja', () {
    test('AppSettingModel serializa y deserializa useShifts correctamente', () {
      final defaultModel = AppSettingModel.fromJson({'id': 'Default', 'createdAt': 1000});
      expect(defaultModel.useShifts, isFalse);

      final enabledModel = AppSettingModel.fromJson({
        'id': 'Default',
        'useShifts': true,
        'createdAt': 1000,
      });
      expect(enabledModel.useShifts, isTrue);
      expect(enabledModel.toJson()['useShifts'], isTrue);

      const update = UpdateAppSetting(useShifts: true);
      expect(update.toJson(), {'useShifts': true});
    });

    test('ShiftInDb y ShiftPreview parsean totales y estado correctamente', () {
      final json = {
        'id': 'shift-1',
        'branchId': 'branch-a',
        'branchName': 'Sucursal Central',
        'docNumber': '0001',
        'status': 'open',
        'initialCash': 50000,
        'openingNotes': 'Inicio',
        'openedBy': {'id': 'u1', 'name': 'Ana Lopez'},
        'openedAt': 1700000000000,
        'invoiceCashTotal': 120000,
        'receiptCashTotal': 30000,
        'cashInTotal': 10000,
        'devolutionTotal': 5000,
        'cashOutTotal': 15000,
        'expectedCash': 190000,
        'countedCash': 0,
        'cashDifference': 0,
        'totalTransfers': 25000,
        'totalCardsAndOthers': 10000,
        'grandTotal': 145000,
        'createdAt': 1700000000000,
      };

      final shift = ShiftInDb.fromJson(json);
      expect(shift.id, 'shift-1');
      expect(shift.status, ShiftStatus.open);
      expect(shift.expectedCash, 190000);

      final preview = ShiftPreview.fromJson(json);
      expect(preview.id, 'shift-1');
      expect(preview.grandTotal, 145000);
    });

    test('CreateShiftCashMovement serializa registerAsExpense y expenseCategory', () {
      const movement = CreateShiftCashMovement(
        branchId: 'branch-a',
        shiftId: 'shift-1',
        type: CashMovementType.outMovement,
        amount: 25000,
        reason: 'Compra de papelería',
        registerAsExpense: true,
        expenseCategory: 'Papelería',
        createdBy: UserInfo(id: 'u1', name: 'Ana Lopez'),
      );

      final json = movement.toJson();
      expect(json['type'], 'out');
      expect(json['registerAsExpense'], isTrue);
      expect(json['expenseCategory'], 'Papelería');
    });

    test('CreateInvoice incluye shiftId solo cuando no es nulo', () {
      final withoutShift = CreateInvoice(
        branchId: 'b1',
        clientId: 'c1',
        clientInfo: ClientInfo(name: 'Cliente', group: ''),
        docNumber: '',
        saleItems: const [],
        status: InvoiceStatus.paid,
        paymentType: PaymentType.cash,
        bankReference: '',
        totalCost: 100,
        total: 200,
        createdBy: const UserInfo(id: 'u1', name: 'ana'),
      );
      expect(withoutShift.toJson().containsKey('shiftId'), isFalse);

      final withShift = CreateInvoice(
        branchId: 'b1',
        clientId: 'c1',
        clientInfo: ClientInfo(name: 'Cliente', group: ''),
        docNumber: '',
        saleItems: const [],
        status: InvoiceStatus.paid,
        paymentType: PaymentType.cash,
        bankReference: '',
        totalCost: 100,
        total: 200,
        createdBy: const UserInfo(id: 'u1', name: 'ana'),
        shiftId: 'shift-99',
      );
      expect(withShift.toJson()['shiftId'], 'shift-99');
    });

    test('ShiftArqueoResponse parsea shift, totals, documentos y meta correctamente', () {
      final arqueo = ShiftArqueoResponse.fromJson({
        'shift': {
          'id': 'shift-1',
          'branchId': 'b1',
          'branchName': 'Central',
          'docNumber': '0001',
          'status': 'open',
          'initialCash': 10000,
          'openedBy': {'id': 'u1', 'name': 'Ana'},
          'openedAt': 1700000000000,
          'createdAt': 1700000000000,
        },
        'totals': {
          'invoiceCashTotal': 50000,
          'invoiceTransferTotal': 15000,
          'receiptTransferTotal': 5000,
          'totalTransfers': 20000,
          'expectedCash': 60000,
          'grandTotal': 80000,
          'invoiceCount': 2,
        },
        'cashMovements': [
          {
            'id': 'm1',
            'branchId': 'b1',
            'shiftId': 'shift-1',
            'docNumber': '0001',
            'type': 'in',
            'amount': 5000,
            'reason': 'Cambio',
            'createdBy': {'id': 'u1', 'name': 'Ana'},
            'createdAt': 1700000001000,
          },
        ],
        'invoices': [
          {
            'id': 'inv1',
            'docNumber': '0010',
            'amount': 50000,
            'paymentMethod': 'cash',
            'status': 'paid',
            'clientName': 'Cliente Demo',
            'createdAt': 1700000002000,
            'counted': true,
          },
        ],
        'receipts': [],
        'devolutions': [],
        'creditNotes': [],
        'meta': {
          'totalsSource': 'live',
          'documentsLimit': 500,
          'truncated': false,
        },
      });

      expect(arqueo.shift.id, 'shift-1');
      expect(arqueo.totals.invoiceTransferTotal, 15000);
      expect(arqueo.totals.receiptTransferTotal, 5000);
      expect(arqueo.totals.expectedCash, 60000);
      expect(arqueo.cashMovements, hasLength(1));
      expect(arqueo.invoices, hasLength(1));
      expect(arqueo.invoices.first.counted, isTrue);
      expect(arqueo.totalDocumentsCount, 1);
      expect(arqueo.meta.isLive, isTrue);
      expect(arqueo.meta.truncated, isFalse);
    });

    test('NumberFormatter.parseMoneyToCents convierte montos enteros y decimales a centavos', () {
      expect(NumberFormatter.parseMoneyToCents('50'), 5000);
      expect(NumberFormatter.parseMoneyToCents('50.25'), 5025);
      expect(NumberFormatter.parseMoneyToCents('50,5'), 5050);
      expect(NumberFormatter.parseMoneyToCents('0'), 0);
      expect(NumberFormatter.parseMoneyToCents(''), 0);
    });
  });

  group('ShiftCubit', () {
    test('Cuando AppSettingsCubit no está registrado, isFeatureEnabled es false y activeShiftId es null', () async {
      final repo = _FakeShiftsRepository();
      final cubit = ShiftCubit(shiftsRepository: repo);

      expect(cubit.isFeatureEnabled, isFalse);
      expect(cubit.activeShiftId, isNull);
      await cubit.loadActiveShift();
      expect(cubit.state, isA<ShiftFeatureDisabled>());

      await cubit.close();
      repo.disposeReactiveRepo();
    });
  });
}
