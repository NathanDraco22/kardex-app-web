import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';
import 'package:kardex_business/src/domain/models/common/payment_detail.dart';
import 'package:kardex_business/src/domain/models/receipt/receipt_model.dart'
    show PaymentMethod;
import 'package:kardex_business/src/tools/number_formatter.dart';

/// Modo de captura del abono según la configuración del negocio.
enum AbonoCaptureMode {
  /// Un solo monto: el valor capturado se usa como abono y como dinero
  /// recibido. Es el comportamiento histórico.
  singleAmount,

  /// Dos montos: abono aplicado y dinero recibido. El cambio se calcula
  /// contra el abono.
  appliedAndReceived,
}

/// Motivos por los que una captura de abono no puede confirmarse.
enum AbonoPaymentError {
  /// La deuda ya está cubierta por devoluciones o notas de crédito.
  debtAlreadyCovered,

  /// No se capturó un monto mayor a cero.
  invalidAmount,

  /// El abono aplicado supera la deuda pendiente.
  amountExceedsDebt,

  /// Se intentó cobrar en moneda secundaria sin una tasa válida.
  invalidExchangeRate,

  /// El dinero recibido no cubre el monto a abonar.
  receivedBelowApplied,

  /// Tarjeta o transferencia sin referencia bancaria.
  missingReference,
}

/// Resultado puro de evaluar la captura de un abono.
class AbonoPaymentDecision {
  const AbonoPaymentDecision({
    required this.mode,
    required this.appliedPrimaryCents,
    required this.receivedPrimaryCents,
    required this.tenderedPaidCents,
    required this.changePrimaryCents,
    this.paymentDetail,
    this.error,
  });

  const AbonoPaymentDecision.invalid({required this.mode, required this.error})
    : appliedPrimaryCents = 0,
      receivedPrimaryCents = 0,
      tenderedPaidCents = 0,
      changePrimaryCents = 0,
      paymentDetail = null;

  final AbonoCaptureMode mode;

  /// Monto que realmente se aplica a la deuda, en centavos de moneda primaria.
  final int appliedPrimaryCents;

  /// Dinero recibido convertido a moneda primaria, en centavos.
  final int receivedPrimaryCents;

  /// Dinero recibido en la moneda en que pagó el cliente, en centavos.
  final int tenderedPaidCents;

  /// Cambio entregado, en centavos de moneda primaria.
  final int changePrimaryCents;

  /// Detalle que debe viajar al recibo. Solo existe para efectivo.
  final PaymentDetail? paymentDetail;

  final AbonoPaymentError? error;

  bool get isValid => error == null;
}

/// Decide cómo capturar y aplicar un abono.
///
/// La bandera [useReceivedAmount] proviene de `AppSettings`:
/// - `false`: se conserva el comportamiento histórico de un solo monto.
/// - `true`: se capturan abono y dinero recibido por separado.
///
/// La policy no conoce Flutter ni hace I/O. Recibe montos en centavos y
/// devuelve los montos aplicados, recibidos y de cambio, además del
/// [PaymentDetail] listo para el recibo.
class AbonoPaymentPolicy {
  const AbonoPaymentPolicy({required this.useReceivedAmount});

  final bool useReceivedAmount;

  AbonoCaptureMode get mode => useReceivedAmount
      ? AbonoCaptureMode.appliedAndReceived
      : AbonoCaptureMode.singleAmount;

  AbonoPaymentDecision evaluate({
    required PaymentMethod method,
    required int maxDebtCents,
    required int appliedInputCents,
    required int receivedInputCents,
    required bool useSecondaryCurrency,
    required AppCurrency primaryCurrency,
    required AppCurrency secondaryCurrency,
    required double exchangeRate,
    required bool hasValidExchangeRate,
    required bool hasReference,
  }) {
    if (maxDebtCents <= 0) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.debtAlreadyCovered,
      );
    }
    if (appliedInputCents <= 0) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.invalidAmount,
      );
    }
    if (useSecondaryCurrency && !hasValidExchangeRate) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.invalidExchangeRate,
      );
    }

    final appliedPrimaryCents = _toPrimaryCents(
      appliedInputCents,
      useSecondaryCurrency: useSecondaryCurrency,
      exchangeRate: exchangeRate,
    );
    if (appliedPrimaryCents <= 0) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.invalidAmount,
      );
    }

    if (method != PaymentMethod.cash) {
      if (appliedPrimaryCents > maxDebtCents) {
        return AbonoPaymentDecision.invalid(
          mode: mode,
          error: AbonoPaymentError.amountExceedsDebt,
        );
      }
      if (!hasReference) {
        return AbonoPaymentDecision.invalid(
          mode: mode,
          error: AbonoPaymentError.missingReference,
        );
      }
      return AbonoPaymentDecision(
        mode: mode,
        appliedPrimaryCents: appliedPrimaryCents,
        receivedPrimaryCents: appliedPrimaryCents,
        tenderedPaidCents: appliedInputCents,
        changePrimaryCents: 0,
      );
    }

    final paidCurrency = useSecondaryCurrency
        ? secondaryCurrency
        : primaryCurrency;
    final paidExchangeRate = useSecondaryCurrency ? exchangeRate : 1.0;

    if (!useReceivedAmount) {
      // Comportamiento histórico: el monto capturado es a la vez abono y
      // dinero recibido. Se aplica hasta la deuda y el excedente es cambio.
      final appliedPrimary = appliedPrimaryCents > maxDebtCents
          ? maxDebtCents
          : appliedPrimaryCents;
      final changePrimary = appliedPrimaryCents > maxDebtCents
          ? appliedPrimaryCents - maxDebtCents
          : 0;

      return AbonoPaymentDecision(
        mode: mode,
        appliedPrimaryCents: appliedPrimary,
        receivedPrimaryCents: appliedPrimaryCents,
        tenderedPaidCents: appliedInputCents,
        changePrimaryCents: changePrimary,
        paymentDetail: PaymentDetail(
          paidCurrency: paidCurrency,
          tenderedAmount: appliedInputCents,
          exchangeRate: paidExchangeRate,
          changeAmount: changePrimary,
        ),
      );
    }

    // Modo separado: el abono no puede superar la deuda y el cambio se mide
    // contra el monto abonado, no contra la deuda completa.
    if (appliedPrimaryCents > maxDebtCents) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.amountExceedsDebt,
      );
    }

    final receivedPaidCents = receivedInputCents > 0
        ? receivedInputCents
        : appliedInputCents;
    final receivedPrimaryCents = _toPrimaryCents(
      receivedPaidCents,
      useSecondaryCurrency: useSecondaryCurrency,
      exchangeRate: exchangeRate,
    );

    if (receivedPrimaryCents < appliedPrimaryCents) {
      return AbonoPaymentDecision.invalid(
        mode: mode,
        error: AbonoPaymentError.receivedBelowApplied,
      );
    }

    final changePrimary = receivedPrimaryCents - appliedPrimaryCents;

    return AbonoPaymentDecision(
      mode: mode,
      appliedPrimaryCents: appliedPrimaryCents,
      receivedPrimaryCents: receivedPrimaryCents,
      tenderedPaidCents: receivedPaidCents,
      changePrimaryCents: changePrimary,
      paymentDetail: PaymentDetail(
        paidCurrency: paidCurrency,
        tenderedAmount: receivedPaidCents,
        exchangeRate: paidExchangeRate,
        changeAmount: changePrimary,
      ),
    );
  }

  int _toPrimaryCents(
    int cents, {
    required bool useSecondaryCurrency,
    required double exchangeRate,
  }) {
    if (!useSecondaryCurrency) return cents;
    return NumberFormatter.convertSecondaryToPrimaryCents(cents, exchangeRate);
  }
}
