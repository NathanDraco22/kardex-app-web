import 'package:intl/intl.dart';
import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';
import 'package:kardex_business/src/tools/unit_display_formatter.dart';

typedef CurrencyResolver = AppCurrency Function();

class SecondaryCurrencyConfig {
  const SecondaryCurrencyConfig({
    required this.currency,
    required this.exchangeRate,
    required this.showInvoiceTotal,
  });

  final AppCurrency currency;
  final double exchangeRate;
  final bool showInvoiceTotal;
}

typedef SecondaryCurrencyResolver = SecondaryCurrencyConfig? Function();

class NumberFormatter {
  static CurrencyResolver? _currencyResolver;
  static SecondaryCurrencyResolver? _secondaryCurrencyResolver;

  static final NumberFormat _instance = NumberFormat.decimalPattern('en_US')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  static void configureCurrencyResolver(CurrencyResolver? resolver) {
    _currencyResolver = resolver;
  }

  static void configureSecondaryCurrencyResolver(
    SecondaryCurrencyResolver? resolver,
  ) {
    _secondaryCurrencyResolver = resolver;
  }

  static AppCurrency get currency =>
      _currencyResolver?.call() ?? AppCurrency.nio;

  static SecondaryCurrencyConfig? get secondaryCurrencyConfig =>
      _secondaryCurrencyResolver?.call();

  static AppCurrency? get secondaryCurrency =>
      secondaryCurrencyConfig?.currency;

  static String get currencySymbol => currency.symbol;

  static NumberFormat get currencyFormat =>
      NumberFormat.currency(symbol: currencySymbol);

  static String formatMoney(int valueInCents, AppCurrency targetCurrency) {
    final valueInCurrency = valueInCents / 100;
    final value = double.parse(valueInCurrency.toStringAsFixed(2));

    return targetCurrency.symbol + _instance.format(value);
  }

  static String convertToMoneyLike(int valueInCents) {
    return formatMoney(valueInCents, currency);
  }

  static String? convertInvoiceTotalToSecondaryMoney(int valueInCents) {
    final config = secondaryCurrencyConfig;
    if (config == null ||
        !config.showInvoiceTotal ||
        config.exchangeRate <= 0 ||
        config.currency == currency) {
      return null;
    }

    final secondaryValueInCents = (valueInCents / config.exchangeRate).round();
    return formatMoney(secondaryValueInCents, config.currency);
  }

  static String decimalPattern(num value) => _instance.format(value);

  static int convertFromDoubleToCents(double value) {
    return (value * 100).round();
  }

  static double convertFromCentsToDouble(int value) {
    return value / 100;
  }

  static String convertFromCentsToUnitsCurrency(int valueInCents) {
    final valueInCurrency = valueInCents / 100;
    final value = double.parse(valueInCurrency.toStringAsFixed(2));

    return _instance.format(value);
  }

  static String formatDisplayStock(
    int stock,
    int factor, {
    String? selectedUnitName,
    String? standardUnitName,
    int? standardUnitFactor,
  }) {
    return UnitDisplayFormatter.formatUnitQuantity(
      baseQuantity: stock,
      conversionFactor: factor,
      selectedUnitName: selectedUnitName,
      standardUnitName: standardUnitName,
      standardUnitFactor: standardUnitFactor,
    ).quantityText;
  }

  /// Convierte un monto ingresado como texto (ej. `"50"` o `"50.25"`) a centavos (`5000`, `5025`).
  static int parseMoneyToCents(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return 0;
    return (parsed * 100).round();
  }
}
