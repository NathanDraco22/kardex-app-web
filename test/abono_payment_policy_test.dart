import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

AbonoPaymentDecision _evaluate({
  bool useReceivedAmount = false,
  PaymentMethod method = PaymentMethod.cash,
  int maxDebtCents = 100000,
  int appliedInputCents = 0,
  int receivedInputCents = 0,
  bool useSecondaryCurrency = false,
  bool hasValidExchangeRate = true,
  bool hasReference = false,
  double exchangeRate = 36.0,
}) {
  return AbonoPaymentPolicy(
    useReceivedAmount: useReceivedAmount,
  ).evaluate(
    method: method,
    maxDebtCents: maxDebtCents,
    appliedInputCents: appliedInputCents,
    receivedInputCents: receivedInputCents,
    useSecondaryCurrency: useSecondaryCurrency,
    primaryCurrency: AppCurrency.nio,
    secondaryCurrency: AppCurrency.usd,
    exchangeRate: exchangeRate,
    hasValidExchangeRate: hasValidExchangeRate,
    hasReference: hasReference,
  );
}

void main() {
  group('modo de captura', () {
    test('sin la bandera usa un solo monto', () {
      const policy = AbonoPaymentPolicy(useReceivedAmount: false);
      expect(policy.mode, AbonoCaptureMode.singleAmount);
    });

    test('con la bandera usa abono y dinero recibido', () {
      const policy = AbonoPaymentPolicy(useReceivedAmount: true);
      expect(policy.mode, AbonoCaptureMode.appliedAndReceived);
    });
  });

  group('modo histórico: un solo monto', () {
    test('efectivo parcial aplica el monto y no genera cambio', () {
      final decision = _evaluate(
        maxDebtCents: 100000,
        appliedInputCents: 50000,
      );

      expect(decision.isValid, isTrue);
      expect(decision.mode, AbonoCaptureMode.singleAmount);
      expect(decision.appliedPrimaryCents, 50000);
      expect(decision.receivedPrimaryCents, 50000);
      expect(decision.changePrimaryCents, 0);
      expect(decision.paymentDetail, isNotNull);
      expect(decision.paymentDetail!.tenderedAmount, 50000);
      expect(decision.paymentDetail!.changeAmount, 0);
      expect(decision.paymentDetail!.paidCurrency, AppCurrency.nio);
      expect(decision.paymentDetail!.exchangeRate, 1.0);
    });

    test('efectivo con sobrepago aplica hasta la deuda y devuelve cambio', () {
      final decision = _evaluate(
        maxDebtCents: 100000,
        appliedInputCents: 120000,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 100000);
      expect(decision.receivedPrimaryCents, 120000);
      expect(decision.changePrimaryCents, 20000);
      expect(decision.paymentDetail!.tenderedAmount, 120000);
      expect(decision.paymentDetail!.changeAmount, 20000);
    });

    test('efectivo en moneda secundaria con sobrepago', () {
      final decision = _evaluate(
        maxDebtCents: 36000,
        appliedInputCents: 1200,
        useSecondaryCurrency: true,
        exchangeRate: 36.0,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 36000);
      expect(decision.receivedPrimaryCents, 43200);
      expect(decision.changePrimaryCents, 7200);
      expect(decision.paymentDetail!.paidCurrency, AppCurrency.usd);
      expect(decision.paymentDetail!.tenderedAmount, 1200);
      expect(decision.paymentDetail!.exchangeRate, 36.0);
      expect(decision.paymentDetail!.changeAmount, 7200);
    });

    test('tarjeta se limita a la deuda y no genera PaymentDetail', () {
      final decision = _evaluate(
        method: PaymentMethod.card,
        maxDebtCents: 100000,
        appliedInputCents: 50000,
        hasReference: true,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 50000);
      expect(decision.changePrimaryCents, 0);
      expect(decision.paymentDetail, isNull);
    });

    test('tarjeta rechaza montos mayores a la deuda', () {
      final decision = _evaluate(
        method: PaymentMethod.card,
        maxDebtCents: 100000,
        appliedInputCents: 120000,
        hasReference: true,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.amountExceedsDebt);
    });

    test('tarjeta exige referencia bancaria', () {
      final decision = _evaluate(
        method: PaymentMethod.card,
        maxDebtCents: 100000,
        appliedInputCents: 50000,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.missingReference);
    });

    test('moneda secundaria sin tasa válida no se puede confirmar', () {
      final decision = _evaluate(
        maxDebtCents: 36000,
        appliedInputCents: 1000,
        useSecondaryCurrency: true,
        hasValidExchangeRate: false,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.invalidExchangeRate);
    });
  });

  group('modo separado: abono y dinero recibido', () {
    test('abono parcial con sobrepago calcula cambio contra el abono', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        maxDebtCents: 100000,
        appliedInputCents: 30000,
        receivedInputCents: 50000,
      );

      expect(decision.isValid, isTrue);
      expect(decision.mode, AbonoCaptureMode.appliedAndReceived);
      expect(decision.appliedPrimaryCents, 30000);
      expect(decision.receivedPrimaryCents, 50000);
      expect(decision.changePrimaryCents, 20000);
      expect(decision.paymentDetail!.tenderedAmount, 50000);
      expect(decision.paymentDetail!.changeAmount, 20000);
    });

    test('recibido vacío se asume igual al abono', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        maxDebtCents: 100000,
        appliedInputCents: 30000,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 30000);
      expect(decision.receivedPrimaryCents, 30000);
      expect(decision.changePrimaryCents, 0);
      expect(decision.paymentDetail!.tenderedAmount, 30000);
      expect(decision.paymentDetail!.changeAmount, 0);
    });

    test('recibido menor al abono no se puede confirmar', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        maxDebtCents: 100000,
        appliedInputCents: 30000,
        receivedInputCents: 20000,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.receivedBelowApplied);
    });

    test('el abono no puede superar la deuda', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        maxDebtCents: 100000,
        appliedInputCents: 120000,
        receivedInputCents: 120000,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.amountExceedsDebt);
    });

    test('moneda secundaria convierte abono, recibido y cambio', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        maxDebtCents: 36000,
        appliedInputCents: 1000,
        receivedInputCents: 1500,
        useSecondaryCurrency: true,
        exchangeRate: 36.0,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 36000);
      expect(decision.receivedPrimaryCents, 54000);
      expect(decision.changePrimaryCents, 18000);
      expect(decision.paymentDetail!.paidCurrency, AppCurrency.usd);
      expect(decision.paymentDetail!.tenderedAmount, 1500);
      expect(decision.paymentDetail!.exchangeRate, 36.0);
      expect(decision.paymentDetail!.changeAmount, 18000);
    });

    test('tarjeta conserva el flujo sin dinero recibido ni cambio', () {
      final decision = _evaluate(
        useReceivedAmount: true,
        method: PaymentMethod.transfer,
        maxDebtCents: 100000,
        appliedInputCents: 50000,
        hasReference: true,
      );

      expect(decision.isValid, isTrue);
      expect(decision.appliedPrimaryCents, 50000);
      expect(decision.changePrimaryCents, 0);
      expect(decision.paymentDetail, isNull);
    });
  });

  group('validaciones comunes', () {
    test('deuda cubierta por devoluciones o notas', () {
      final decision = _evaluate(
        maxDebtCents: 0,
        appliedInputCents: 10000,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.debtAlreadyCovered);
    });

    test('monto en cero o negativo', () {
      final decision = _evaluate(
        maxDebtCents: 100000,
        appliedInputCents: 0,
      );

      expect(decision.isValid, isFalse);
      expect(decision.error, AbonoPaymentError.invalidAmount);
    });
  });
}
