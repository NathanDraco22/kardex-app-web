import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';

/// Configuración vigente para mostrar el total de facturas en la moneda
/// secundaria.
///
/// Solo existe cuando la opción está habilitada, las monedas son distintas y
/// la tasa de cambio es mayor que cero.
class SecondaryCurrencyDisplay {
  const SecondaryCurrencyDisplay({
    required this.primaryCurrency,
    required this.secondaryCurrency,
    required this.exchangeRate,
  });

  final AppCurrency primaryCurrency;
  final AppCurrency secondaryCurrency;

  /// Unidades de moneda principal por una unidad de moneda secundaria.
  final double exchangeRate;
}
