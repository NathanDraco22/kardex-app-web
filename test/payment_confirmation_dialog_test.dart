import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<PaymentResult? Function()> openPaymentDialog(
    WidgetTester tester, {
    String? warningText,
    Size surfaceSize = const Size(1200, 1600),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    PaymentResult? result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showPaymentConfirmationDialog(
                    context,
                    1000,
                    warningText: warningText,
                  );
                },
                child: const Text('Abrir pago'),
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Abrir pago'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return () => result;
  }

  testWidgets('efectivo primario calcula cambio y guarda PaymentDetail', (tester) async {
    final readResult = await openPaymentDialog(
      tester,
      warningText: 'Aviso de acción irreversible',
    );

    expect(find.text('Aviso de acción irreversible'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();

    expect(find.textContaining('Cambio:'), findsOneWidget);

    await tester.drag(find.text('Confirmar'), const Offset(350, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    final result = readResult();
    expect(result, isNotNull);
    if (result == null) return;
    expect(result.method, PaymentType.cash);
    final detail = result.paymentDetail;
    expect(detail, isNotNull);
    if (detail == null) return;
    expect(detail.paidCurrency, AppCurrency.nio);
    expect(detail.tenderedAmount, 1500);
    expect(detail.changeAmount, 500);
    expect(detail.exchangeRate, 1.0);
  });

  testWidgets('tarjeta exige referencia y no genera PaymentDetail', (tester) async {
    final readResult = await openPaymentDialog(tester);

    await tester.tap(find.text('Tarjeta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();

    await tester.drag(find.text('Confirmar'), const Offset(350, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    final result = readResult();
    expect(result, isNotNull);
    if (result == null) return;
    expect(result.method, PaymentType.card);
    expect(result.reference, '12345');
    expect(result.paymentDetail, isNull);
  });

  testWidgets('no desborda en una pantalla angosta con aviso', (tester) async {
    final readResult = await openPaymentDialog(
      tester,
      warningText: 'Se aplicará el abono. Esta acción no se puede revertir.',
      surfaceSize: const Size(360, 640),
    );

    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();

    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -400),
    );
    await tester.pump();

    await tester.drag(find.text('Confirmar'), const Offset(280, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    final result = readResult();
    expect(result, isNotNull);
  });
}
