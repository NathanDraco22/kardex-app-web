/// Resultado del cálculo de precio sugerido a partir de un costo y el margen
/// por defecto configurado.
class SuggestedPrice {
  const SuggestedPrice({
    required this.costInCents,
    required this.priceInCents,
    required this.marginPercent,
    required this.unitFactor,
  });

  /// Costo base en centavos.
  final int costInCents;

  /// Precio sugerido para una unidad base, en centavos.
  final int priceInCents;

  /// Porcentaje de margen aplicado.
  final double marginPercent;

  /// Factor de la unidad seleccionada (por ejemplo, una caja de 12 unidades).
  final int unitFactor;

  /// Precio sugerido equivalente para la unidad seleccionada.
  int get totalPriceInCents => priceInCents * unitFactor;

  /// Costo equivalente para la unidad seleccionada.
  int get totalCostInCents => costInCents * unitFactor;
}
