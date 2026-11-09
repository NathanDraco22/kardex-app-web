import 'dart:math' as math;

/// Tolerancia usada para aceptar cantidades que, por punto flotante, quedan
/// muy cerca de un múltiplo exacto de `1 / conversionFactor`.
const double creditNoteQuantityTolerance = 1e-9;

/// Resultado del cálculo de una línea devuelta.
sealed class CreditNoteLineResult {
  const CreditNoteLineResult();
}

/// La línea no tiene cantidad capturada; el diálogo la ignora.
final class CreditNoteLineSkipped extends CreditNoteLineResult {
  const CreditNoteLineSkipped();
}

/// La cantidad capturada no es válida y debe mostrarse al usuario.
final class CreditNoteLineInvalid extends CreditNoteLineResult {
  const CreditNoteLineInvalid(this.message);

  final String message;
}

/// Importes ya prorrateados y expresados en unidad base.
final class CreditNoteLineAmounts extends CreditNoteLineResult {
  const CreditNoteLineAmounts({
    required this.quantity,
    required this.subTotal,
    required this.totalDiscount,
    required this.total,
  });

  final int quantity;
  final int subTotal;
  final int totalDiscount;
  final int total;
}

/// Convierte una cantidad comercial a unidades base y prorratea los importes
/// de la línea facturada con división entera (`~/`) y `max(0, ...)`.
CreditNoteLineResult calculateCreditNoteLine({
  required double displayQuantity,
  required int conversionFactor,
  required int invoiceQuantity,
  required int invoiceSubTotal,
  required int invoiceTotal,
  int previouslyReturnedBase = 0,
}) {
  if (displayQuantity <= 0) {
    return const CreditNoteLineSkipped();
  }
  if (!displayQuantity.isFinite) {
    return const CreditNoteLineInvalid('La cantidad ingresada no es válida.');
  }

  final factor = math.max(conversionFactor, 1);
  final scaled = displayQuantity * factor;
  final nearest = scaled.roundToDouble();

  if ((scaled - nearest).abs() > creditNoteQuantityTolerance) {
    return CreditNoteLineInvalid(
      'La cantidad debe ser múltiplo exacto del paso mínimo (1/$factor).',
    );
  }

  // Se normaliza primero contra la deriva de punto flotante y luego se aplica
  // floor, de modo que nunca se redondea hacia arriba una fracción real.
  final baseQuantity = nearest.floor();

  if (baseQuantity <= 0) {
    return const CreditNoteLineInvalid(
      'La cantidad equivalente en unidad base debe ser mayor a 0.',
    );
  }
  if (invoiceQuantity <= 0) {
    return const CreditNoteLineInvalid(
      'La línea facturada no tiene una cantidad válida.',
    );
  }
  if (previouslyReturnedBase < 0) {
    return const CreditNoteLineInvalid(
      'El acumulado devuelto de la línea no es válido.',
    );
  }

  final remaining = invoiceQuantity - previouslyReturnedBase;
  if (remaining <= 0) {
    return const CreditNoteLineInvalid(
      'Esta línea ya fue devuelta en su totalidad.',
    );
  }
  if (baseQuantity > remaining) {
    return CreditNoteLineInvalid(
      'La cantidad supera el máximo devolvible ($remaining en unidad base).',
    );
  }

  final subTotal = (invoiceSubTotal * baseQuantity) ~/ invoiceQuantity;
  final total = (invoiceTotal * baseQuantity) ~/ invoiceQuantity;

  return CreditNoteLineAmounts(
    quantity: baseQuantity,
    subTotal: subTotal,
    totalDiscount: math.max(0, subTotal - total),
    total: total,
  );
}

/// Genera una llave de idempotencia UUID v4 local sin agregar dependencias.
String generateCreditNoteIdempotencyKey({math.Random? random}) {
  final rng = random ?? math.Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
