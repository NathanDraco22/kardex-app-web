/// Estado de una función que depende de la moneda secundaria.
///
/// Distingue “deshabilitada” de “mal configurada” para que la UI pueda mostrar
/// una advertencia útil en lugar de ocultar la función sin explicación.
enum SecondaryCurrencyAvailability {
  /// La función está apagada en ajustes.
  disabled,

  /// La moneda secundaria coincide con la principal.
  sameCurrency,

  /// La función está activada, pero falta una tasa de cambio válida.
  missingExchangeRate,

  /// La función está activada y tiene moneda y tasa válidas.
  available;

  /// La función está activada y usa una moneda distinta a la principal,
  /// aunque todavía falte la tasa.
  bool get isFeatureEnabled =>
      this == SecondaryCurrencyAvailability.missingExchangeRate ||
      this == SecondaryCurrencyAvailability.available;

  /// La función puede ejecutarse (moneda distinta y tasa válida).
  bool get isAvailable => this == SecondaryCurrencyAvailability.available;
}
