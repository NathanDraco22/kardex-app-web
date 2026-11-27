import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/fast_payment_modal.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  Future<FastPaymentResult? Function()> openFastPaymentModal(
    WidgetTester tester, {
    required double maxAmountToPay,
  }) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FastPaymentResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<FastPaymentResult>(
                    context: context,
                    builder: (_) => FastPaymentModal(
                      maxAmountToPay: maxAmountToPay,
                      clientName: 'Cliente de prueba',
                    ),
                  );
                },
                child: const Text('Abrir abono'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir abono'));
    await tester.pumpAndSettle();
    return () => result;
  }

  testWidgets('Abono rápido permite cambio en efectivo primario', (tester) async {
    final readResult = await openFastPaymentModal(tester, maxAmountToPay: 4.5);

    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();

    expect(find.textContaining('Se aplican:'), findsOneWidget);
    expect(find.textContaining('Cambio:'), findsOneWidget);

    await tester.tap(find.text('Aplicar Abono'));
    await tester.pumpAndSettle();

    final result = readResult();
    expect(result, isNotNull);
    if (result == null) return;
    expect(result.amount, 4.5);
    expect(result.method, PaymentMethod.cash);
    expect(result.paymentDetail, isNotNull);
    final detail = result.paymentDetail;
    if (detail == null) return;
    expect(detail.paidCurrency, AppCurrency.nio);
    expect(detail.tenderedAmount, 500);
    expect(detail.changeAmount, 50);
    expect(detail.exchangeRate, 1.0);
  });

  testWidgets('Abono rápido con tarjeta no permite exceder la deuda', (tester) async {
    await openFastPaymentModal(tester, maxAmountToPay: 4.5);

    await tester.tap(find.text('Tarjeta'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '5');
    await tester.pump();

    expect(find.text('El monto excede la deuda total'), findsOneWidget);
  });
}
