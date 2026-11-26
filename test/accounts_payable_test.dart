import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/accounts_payable/view/accounts_payable_screen.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/dialogs/register_expense_payment_dialog.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeExpensesRepository extends ExpensesRepository {
  _FakeExpensesRepository({
    required this.summary,
  }) : super(ExpensesDataSource.instance);

  final AccountsPayableSummary summary;
  AddToAmountRequest? lastPaymentRequest;

  @override
  Future<AccountsPayableSummary> getAccountsPayableSummary({
    String? branchId,
    int? overdueCutoffMs,
  }) async {
    return summary;
  }

  @override
  Future<ExpenseInDb> addToAmountPaid(AddToAmountRequest request) async {
    lastPaymentRequest = request;
    return ExpenseInDb(
      id: request.expenseId,
      createdAt: DateTime(2026, 11, 10),
      branchId: 'b-1',
      amount: 10000,
      amountPaid: request.amountPaid,
      category: '',
      date: DateTime(2026, 11, 10).millisecondsSinceEpoch,
      dateId: '2026-11-10',
      status: request.amountPaid >= 10000 ? ExpenseStatus.paid : ExpenseStatus.partiallyPaid,
      type: ExpenseType.supplier,
      supplierId: 's-1',
      supplierName: 'Proveedor Uno',
      createdBy: const UserInfo(id: 'u-1', name: 'Admin'),
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('ExpenseInDb y abonos', () {
    test('deserializa amountPaid, payments y calcula remainingAmount', () {
      final expense = ExpenseInDb.fromJson({
        'id': 'exp-1',
        'createdAt': DateTime(2026, 11, 10).millisecondsSinceEpoch,
        'branchId': 'b-1',
        'docNumber': 'F-100',
        'amount': 15000,
        'amountPaid': 4500,
        'payments': [
          {
            'id': 'p-1',
            'amount': 4500,
            'paymentMethod': 'transfer',
            'reference': 'TRF-1',
            'note': 'Abono inicial',
            'paidAt': DateTime(2026, 11, 11).millisecondsSinceEpoch,
            'createdBy': {'id': 'u-1', 'name': 'Ana'},
            'createdAt': DateTime(2026, 11, 11).millisecondsSinceEpoch,
          },
        ],
        'category': '',
        'date': DateTime(2026, 11, 10).millisecondsSinceEpoch,
        'dateId': '2026-11-10',
        'status': 'partiallyPaid',
        'type': 'supplier',
        'supplierId': 's-1',
        'supplierName': 'Distribuidora',
        'createdBy': {'id': 'u-1', 'name': 'Ana'},
      });

      expect(expense.effectiveAmountPaid, 4500);
      expect(expense.remainingAmount, 10500);
      expect(expense.payments, hasLength(1));
      expect(expense.payments.first.paymentMethod, ExpensePaymentMethod.transfer);
      expect(expense.payments.first.reference, 'TRF-1');
    });

    test('describeExpenseDueDate genera etiquetas relativas precisas', () {
      final now = DateTime(2026, 11, 26, 11, 0);

      final overdue = describeExpenseDueDate(
        DateTime(2026, 11, 21).millisecondsSinceEpoch,
        status: ExpenseStatus.open,
        now: now,
      );
      expect(overdue.label, 'Venció hace 5 días');
      expect(overdue.urgency, ExpenseDueUrgency.overdue);

      final today = describeExpenseDueDate(
        DateTime(2026, 11, 26).millisecondsSinceEpoch,
        status: ExpenseStatus.open,
        now: now,
      );
      expect(today.label, 'Vence hoy');
      expect(today.urgency, ExpenseDueUrgency.soon);

      final tomorrow = describeExpenseDueDate(
        DateTime(2026, 11, 27).millisecondsSinceEpoch,
        status: ExpenseStatus.open,
        now: now,
      );
      expect(tomorrow.label, 'Vence mañana');
      expect(tomorrow.urgency, ExpenseDueUrgency.soon);

      final inFourDays = describeExpenseDueDate(
        DateTime(2026, 11, 30).millisecondsSinceEpoch,
        status: ExpenseStatus.open,
        now: now,
      );
      expect(inFourDays.label, 'Vence en 4 días');
      expect(inFourDays.urgency, ExpenseDueUrgency.soon);
    });
  });

  group('AccountsPayableScreen', () {
    testWidgets('muestra KPIs, filtros y lista de proveedores', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeExpensesRepository(
        summary: AccountsPayableSummary(
          totalPending: 25000,
          totalOverdue: 15000,
          suppliersCount: 2,
          documentsCount: 3,
          suppliers: [
            SupplierPayableSummary(
              supplierId: 's-1',
              supplierName: 'Distribuidora Norte',
              totalAmount: 20000,
              totalPaid: 5000,
              pendingAmount: 15000,
              overdueAmount: 15000,
              pendingCount: 2,
              overdueCount: 1,
              oldestDueDate: DateTime(2026, 11, 1).millisecondsSinceEpoch,
            ),
            SupplierPayableSummary(
              supplierId: 's-2',
              supplierName: 'Importadora Sur',
              totalAmount: 10000,
              totalPaid: 0,
              pendingAmount: 10000,
              overdueAmount: 0,
              pendingCount: 1,
              overdueCount: 0,
              oldestDueDate: DateTime(2026, 12, 15).millisecondsSinceEpoch,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        RepositoryProvider<ExpensesRepository>.value(
          value: repo,
          child: const MaterialApp(
            home: AccountsPayableScreen(branchId: 'b-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Cuentas por Pagar'), findsOneWidget);
      expect(find.text('Total por Pagar'), findsOneWidget);
      expect(find.text('Total Vencido'), findsOneWidget);
      expect(find.text('Distribuidora Norte'), findsOneWidget);
      expect(find.text('Importadora Sur'), findsOneWidget);

      await tester.tap(find.text('Solo con vencidos'));
      await tester.pumpAndSettle();

      expect(find.text('Distribuidora Norte'), findsOneWidget);
      expect(find.text('Importadora Sur'), findsNothing);
    });
  });

  group('RegisterExpensePaymentView', () {
    testWidgets('valida sobrepago y permite llenar saldo completo', (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeExpensesRepository(summary: const AccountsPayableSummary());
      final writeCubit = WriteExpenseCubit(repo);
      final expense = ExpenseInDb(
        id: 'exp-1',
        createdAt: DateTime(2026, 11, 10),
        branchId: 'b-1',
        docNumber: 'FAC-1',
        amount: 10000,
        amountPaid: 2500,
        category: '',
        date: DateTime(2026, 11, 10).millisecondsSinceEpoch,
        dateId: '2026-11-10',
        status: ExpenseStatus.partiallyPaid,
        type: ExpenseType.supplier,
        supplierId: 's-1',
        supplierName: 'Proveedor Uno',
        createdBy: const UserInfo(id: 'u-1', name: 'Admin'),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: writeCubit,
          child: MaterialApp(
            home: Scaffold(
              body: RegisterExpensePaymentView(
                expense: expense,
                currentUser: const UserInfo(id: 'u-1', name: 'Admin'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '90.00');
      await tester.tap(find.text('Registrar Abono').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('No puede exceder el saldo'), findsOneWidget);
      expect(repo.lastPaymentRequest, isNull);

      await tester.tap(find.text('Saldo total'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar Abono').last);
      await tester.pumpAndSettle();

      expect(repo.lastPaymentRequest, isNotNull);
      expect(repo.lastPaymentRequest!.amountPaid, 7500);
    });

    test('ExpenseActionPermissions bloquea editar o eliminar gastos con abonos', () {
      final now = DateTime.now();
      final openRecent = ExpenseInDb(
        id: 'e-open',
        createdAt: now,
        branchId: 'b-1',
        amount: 10000,
        category: '',
        date: now.millisecondsSinceEpoch,
        dateId: '2026-11-26',
        status: ExpenseStatus.open,
        type: ExpenseType.supplier,
        createdBy: const UserInfo(id: 'u-1', name: 'Admin'),
      );
      expect(ExpenseActionPermissions.canEditOrDelete(openRecent), isTrue);

      final withPayments = ExpenseInDb(
        id: 'e-partial',
        createdAt: now,
        branchId: 'b-1',
        amount: 10000,
        amountPaid: 2000,
        payments: [
          ExpensePayment(
            id: 'p-1',
            amount: 2000,
            paidAt: now.millisecondsSinceEpoch,
            createdAt: now.millisecondsSinceEpoch,
          ),
        ],
        category: '',
        date: now.millisecondsSinceEpoch,
        dateId: '2026-11-26',
        status: ExpenseStatus.partiallyPaid,
        type: ExpenseType.supplier,
        createdBy: const UserInfo(id: 'u-1', name: 'Admin'),
      );
      expect(ExpenseActionPermissions.canEditOrDelete(withPayments), isFalse);
    });
  });
}
