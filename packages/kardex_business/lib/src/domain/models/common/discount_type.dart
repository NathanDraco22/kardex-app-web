import 'dart:math' as math;

/// Tipo de descuento aplicable a una línea o a una factura completa.
enum DiscountType {
  percentage('percentage'),
  amount('amount');

  const DiscountType(this.apiValue);

  final String apiValue;

  static DiscountType? tryFromApi(String? value) {
    if (value == null) return null;
    for (final type in DiscountType.values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }

  /// Calcula el monto descontado en centavos dado un [baseAmount] en centavos
  /// y un [discountValue] (porcentaje entero 0..100 o monto en centavos).
  static int calculateDiscountAmount({
    required DiscountType? type,
    required int discountValue,
    required int baseAmount,
  }) {
    if (type == null || discountValue <= 0 || baseAmount <= 0) return 0;
    switch (type) {
      case DiscountType.percentage:
        final pct = discountValue.clamp(0, 100);
        return (baseAmount * (pct / 100)).round().clamp(0, baseAmount);
      case DiscountType.amount:
        return math.min(discountValue, baseAmount).clamp(0, baseAmount);
    }
  }

  /// Formatea el porcentaje que representa [discountAmount] respecto a [baseAmount].
  /// Retorna vacío si alguno es `<= 0`.
  static String formatEquivalentPercentage({
    required int discountAmount,
    required int baseAmount,
  }) {
    if (discountAmount <= 0 || baseAmount <= 0) return '';
    final scaled = discountAmount * 100;
    if (scaled % baseAmount == 0) {
      return '${scaled ~/ baseAmount}%';
    }
    final pct = scaled / baseAmount;
    final formatted = pct.toStringAsFixed(1);
    return formatted.endsWith('.0')
        ? '${formatted.substring(0, formatted.length - 2)}%'
        : '$formatted%';
  }
}
