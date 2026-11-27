import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/partial_payment_modal.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Abonar captura método, monto recibido y cambio', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ClientInDb(
      id: 'client-1',
      name: 'Cliente Demo',
      group: 'General',
      createdAt: DateTime(2026, 11, 27),
    );
    final invoice = InvoiceInDb(
      id: 'inv-1',
      docNumber: 'FAC-001',
      branchId: 'branch-1',
      clientId: client.id,
      clientInfo: ClientInfo(name: client.name, group: client.group),
      paymentType: PaymentType.credit,
      bankReference: '',
      status: InvoiceStatus.open,
      saleItems: const [],
      totalCost: 500,
      invoiceDiscount: 0,
      total: 1000,
      amountPaid: 0,
      createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      createdAt: DateTime(2026, 11, 27),
    );

    PartialPaymentResult? result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showPartialPaymentModal(
                    context,
                    client: client,
                    invoices: [invoice],
                    devolutions: const [],
                  );
                },
                child: const Text('Abrir abono'),
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Abrir abono'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();
    await tester.tap(find.text('Confirmar Abonos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Total a Pagar: C\$10.00'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '15');
    await tester.pump();

    expect(find.textContaining('Cambio:'), findsOneWidget);

    await tester.drag(find.text('Confirmar'), const Offset(350, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));

    expect(result, isNotNull);
    if (result == null) return;
    expect(result!.payments[invoice.id], 10.0);
    expect(result!.payment, isNotNull);
    final payment = result!.payment;
    if (payment == null) return;
    expect(payment.method, PaymentType.cash);
    expect(payment.receiptPaymentMethod, PaymentMethod.cash);
    final detail = payment.paymentDetail;
    expect(detail, isNotNull);
    if (detail == null) return;
    expect(detail.tenderedAmount, 1500);
    expect(detail.changeAmount, 500);
  });

  testWidgets('muestra notas por monto sin desbordar a 360 px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ClientInDb(
      id: 'client-1',
      name: 'Cliente Demo',
      group: 'General',
      createdAt: DateTime(2026, 11, 27),
    );
    final invoice = InvoiceInDb(
      id: 'inv-1',
      docNumber: 'FAC-001',
      branchId: 'branch-1',
      clientId: client.id,
      clientInfo: ClientInfo(name: client.name, group: client.group),
      paymentType: PaymentType.credit,
      bankReference: '',
      status: InvoiceStatus.open,
      saleItems: const [],
      totalCost: 500,
      invoiceDiscount: 0,
      total: 1000,
      amountPaid: 0,
      createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      createdAt: DateTime(2026, 11, 27),
    );
    final note = CreditNoteInDb(
      id: 'cn-1',
      branchId: 'branch-1',
      clientId: client.id,
      clientInfo: ClientInfo(name: client.name, group: client.group),
      type: CreditNoteType.amount,
      docNumber: 'NC-001',
      amount: 500,
      status: CreditNoteStatus.confirmed,
      createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      createdAt: DateTime(2026, 11, 27),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showPartialPaymentModal(
                  context,
                  client: client,
                  invoices: [invoice],
                  devolutions: const [],
                  creditNotes: [note],
                ),
                child: const Text('Abrir abono'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir abono'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Notas por monto:'), findsOneWidget);
    expect(find.text('Confirmar Abonos'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  });
}
