import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/fast_payment_modal.dart';
import 'package:kardex_business/kardex_business.dart';

const _amountField = Key('fast-payment-amount-field');
const _receivedField = Key('fast-payment-received-field');

void main() {
  Future<FastPaymentResult? Function()> openFastPaymentModal(
    WidgetTester tester, {
    required double maxAmountToPay,
    bool useReceivedAmount = false,
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
                      useReceivedAmount: useReceivedAmount,
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

  testWidgets('modo histórico permite cambio al superar la deuda', (
    tester,
  ) async {
    final readResult = await openFastPaymentModal(tester, maxAmountToPay: 4.5);

    await tester.enterText(find.byKey(_amountField), '5');
    await tester.pump();

    expect(find.byKey(_receivedField), findsNothing);
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

  testWidgets('modo separado calcula cambio contra el abono', (tester) async {
    final readResult = await openFastPaymentModal(
      tester,
      maxAmountToPay: 10,
      useReceivedAmount: true,
    );

    await tester.enterText(find.byKey(_amountField), '3');
    await tester.pump();
    await tester.enterText(find.byKey(_receivedField), '5');
    await tester.pump();

    expect(find.textContaining('Se aplican:'), findsOneWidget);
    expect(find.textContaining('Cambio:'), findsOneWidget);

    await tester.tap(find.text('Aplicar Abono'));
    await tester.pumpAndSettle();

    final result = readResult();
    expect(result, isNotNull);
    if (result == null) return;
    expect(result.amount, 3.0);
    expect(result.paymentDetail, isNotNull);
    final detail = result.paymentDetail;
    if (detail == null) return;
    expect(detail.tenderedAmount, 500);
    expect(detail.changeAmount, 200);
  });

  testWidgets('recibido vacío se registra igual al abono', (tester) async {
    final readResult = await openFastPaymentModal(
      tester,
      maxAmountToPay: 10,
      useReceivedAmount: true,
    );

    await tester.enterText(find.byKey(_amountField), '3');
    await tester.pump();

    expect(find.textContaining('Cambio:'), findsOneWidget);

    await tester.tap(find.text('Aplicar Abono'));
    await tester.pumpAndSettle();

    final result = readResult();
    expect(result, isNotNull);
    if (result == null) return;
    expect(result.amount, 3.0);
    expect(result.paymentDetail, isNotNull);
    expect(result.paymentDetail!.tenderedAmount, 300);
    expect(result.paymentDetail!.changeAmount, 0);
  });

  testWidgets('recibido menor al abono bloquea la confirmación', (
    tester,
  ) async {
    final readResult = await openFastPaymentModal(
      tester,
      maxAmountToPay: 10,
      useReceivedAmount: true,
    );

    await tester.enterText(find.byKey(_amountField), '3');
    await tester.pump();
    await tester.enterText(find.byKey(_receivedField), '2');
    await tester.pump();

    expect(
      find.text('El dinero recibido no cubre el abono'),
      findsOneWidget,
    );

    await tester.tap(find.text('Aplicar Abono'));
    await tester.pumpAndSettle();
    expect(readResult(), isNull);
  });

  testWidgets('modo separado no muestra recibido en tarjeta', (tester) async {
    await openFastPaymentModal(
      tester,
      maxAmountToPay: 10,
      useReceivedAmount: true,
    );

    await tester.tap(find.text('Tarjeta'));
    await tester.pumpAndSettle();

    expect(find.byKey(_receivedField), findsNothing);

    await tester.enterText(find.byKey(_amountField), '15');
    await tester.pump();

    expect(find.text('El monto excede la deuda total'), findsOneWidget);
  });

  testWidgets('modo histórico con tarjeta no permite exceder la deuda', (
    tester,
  ) async {
    await openFastPaymentModal(tester, maxAmountToPay: 4.5);

    await tester.tap(find.text('Tarjeta'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(_amountField), '5');
    await tester.pump();

    expect(find.text('El monto excede la deuda total'), findsOneWidget);
  });

  testWidgets('modo separado no desborda a 360 px', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FastPaymentModal(
            maxAmountToPay: 1000,
            clientName: 'Cliente con nombre largo para probar el layout',
            useReceivedAmount: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(_amountField), '300');
    await tester.pump();
    await tester.enterText(find.byKey(_receivedField), '500');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
