import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';

/// Condiciones vigentes para cobrar en la moneda secundaria.
///
/// Solo existe cuando la función está habilitada, las monedas son distintas y
/// la tasa de cambio es mayor que cero.
class SecondaryCurrencyPaymentTerms {
  const SecondaryCurrencyPaymentTerms({
    required this.primaryCurrency,
    required this.secondaryCurrency,
    required this.exchangeRate,
  });

  final AppCurrency primaryCurrency;
  final AppCurrency secondaryCurrency;

  /// Unidades de moneda principal por una unidad de moneda secundaria.
  final double exchangeRate;
}
