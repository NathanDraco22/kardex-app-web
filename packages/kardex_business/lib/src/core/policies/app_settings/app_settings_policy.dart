import 'package:kardex_business/src/core/policies/clients/client_price_preference_policy.dart';
import 'package:kardex_business/src/core/policies/receipts/abono_payment_policy.dart';
import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';
import 'package:kardex_business/src/domain/models/app_setting/app_setting_model.dart';
import 'package:kardex_business/src/domain/models/app_setting/app_tax_id_label.dart';
import 'package:kardex_business/src/domain/models/client/client_model.dart';
import 'package:kardex_business/src/domain/models/invoice/invoice_model.dart';

import 'converted_order_shift_policy.dart';
import 'secondary_currency_availability.dart';
import 'secondary_currency_display.dart';
import 'secondary_currency_payment_terms.dart';
import 'suggested_price.dart';

/// Política de decisiones derivadas de la configuración global del negocio.
///
/// El objeto es puro: no hace I/O, no conoce Flutter ni mantiene estado. El
/// `AppSettingsCubit` lo construye a partir de `currentSettings` y lo expone
/// como `policy`.
///
/// Convención de retorno:
/// - una decisión binaria devuelve `bool`;
/// - varias decisiones excluyentes devuelven un `enum`;
/// - un resultado que puede existir o no devuelve un objeto opcional;
/// - un resultado compuesto que siempre existe devuelve un objeto respuesta.
final class AppSettingsPolicy {
  const AppSettingsPolicy([this.settings = AppSettingModel.defaults]);

  final AppSettingModel settings;

  // ── Datos base ───────────────────────────────────────────────────────────

  AppCurrency get currency => settings.currency;
  AppCurrency get secondaryCurrency => settings.secondaryCurrency;
  double get exchangeRate => settings.exchangeRate;
  int get defaultPaymentTermDays => settings.defaultPaymentTermDays;

  String get taxIdLabel {
    final value = settings.taxIdLabel.trim();
    return value.isEmpty ? 'RUC' : value;
  }

  // ── Banderas simples ────────────────────────────────────────────────────

  bool get useExpirationDates => settings.useExpirationDates;
  bool get useOrders => settings.useOrders;
  bool get useQuotations => settings.useQuotations;
  bool get allowNegativeStock => settings.allowNegativeStock;
  bool get alertMinStock => settings.alertMinStock;
  bool get useHoldSales => settings.useHoldSales;
  bool get useQuickProductSearch => settings.useQuickProductSearch;
  bool get useShifts => settings.useShifts;
  bool get chargeConvertedOrdersToShift =>
      settings.chargeConvertedOrdersToShift;
  bool get requireShiftForConvertedOrders =>
      settings.requireShiftForConvertedOrders;
  bool get useInvoiceCancellations => settings.useInvoiceCancellations;
  bool get useReceiptCancellations => settings.useReceiptCancellations;
  bool get allowCancellationsOutsideShift =>
      settings.allowCancellationsOutsideShift;
  bool get useDiscounts => settings.useDiscounts;
  bool get roundUpInvoiceTotals => settings.roundUpInvoiceTotals;
  bool get useClientPreferredPrices => settings.useClientPreferredPrices;
  bool get useDefaultProfitMargin => settings.useDefaultProfitMargin;
  double get defaultProfitMargin => settings.defaultProfitMargin;
  bool get showInvoiceItemsSummary => settings.showInvoiceItemsSummary;
  bool get showInvoiceOrderCreator => settings.showInvoiceOrderCreator;
  bool get showInvoiceTotalInSecondaryCurrency =>
      settings.showInvoiceTotalInSecondaryCurrency;
  bool get allowSecondaryCurrencyPayment =>
      settings.allowSecondaryCurrencyPayment;
  bool get useAbonoReceivedAmount => settings.useAbonoReceivedAmount;

  /// Política de captura del abono rápido. La bandera decide si se usa el
  /// modo histórico de un monto o el modo de abono + dinero recibido.
  AbonoPaymentPolicy get abonoPaymentPolicy =>
      AbonoPaymentPolicy(useReceivedAmount: useAbonoReceivedAmount);

  /// Preferencia de precio del cliente según la bandera global.
  ClientPricePreferencePolicy clientPricePreferenceFor(ClientInDb? client) =>
      ClientPricePreferencePolicy(
        client: client,
        enabled: useClientPreferredPrices,
      );

  // ── Decisiones binarias derivadas ───────────────────────────────────────

  bool get hasExchangeRate => exchangeRate > 0;

  bool get hasCompanyLogo => companyLogoUrl != null;

  /// La tasa de cambio es visible cuando al menos una función de moneda
  /// secundaria está activa y las monedas son distintas.
  bool get showsExchangeRateStatus =>
      secondaryCurrency != currency &&
      (allowSecondaryCurrencyPayment || showInvoiceTotalInSecondaryCurrency);

  /// La función de cobro está activa aunque falte la tasa (para mostrar la
  /// advertencia correspondiente).
  bool get offersSecondaryCurrencyPayment =>
      paymentAvailability.isFeatureEnabled;

  // ── Varias salidas: enum ────────────────────────────────────────────────

  ConvertedOrderShiftPolicy get convertedOrderShiftPolicy {
    if (!useShifts || !chargeConvertedOrdersToShift) {
      return ConvertedOrderShiftPolicy.never;
    }
    return requireShiftForConvertedOrders
        ? ConvertedOrderShiftPolicy.required
        : ConvertedOrderShiftPolicy.optional;
  }

  SecondaryCurrencyAvailability get paymentAvailability =>
      _secondaryCurrencyAvailability(enabled: allowSecondaryCurrencyPayment);

  SecondaryCurrencyAvailability get invoiceDisplayAvailability =>
      _secondaryCurrencyAvailability(
        enabled: showInvoiceTotalInSecondaryCurrency,
      );

  SecondaryCurrencyAvailability _secondaryCurrencyAvailability({
    required bool enabled,
  }) {
    if (!enabled) {
      return SecondaryCurrencyAvailability.disabled;
    }
    if (secondaryCurrency == currency) {
      return SecondaryCurrencyAvailability.sameCurrency;
    }
    if (!hasExchangeRate) {
      return SecondaryCurrencyAvailability.missingExchangeRate;
    }
    return SecondaryCurrencyAvailability.available;
  }

  // ── Existe o no: objetos opcionales ─────────────────────────────────────

  SecondaryCurrencyPaymentTerms? get secondaryCurrencyPaymentTerms {
    if (!paymentAvailability.isAvailable) {
      return null;
    }
    return SecondaryCurrencyPaymentTerms(
      primaryCurrency: currency,
      secondaryCurrency: secondaryCurrency,
      exchangeRate: exchangeRate,
    );
  }

  SecondaryCurrencyDisplay? get invoiceSecondaryCurrencyDisplay {
    if (!invoiceDisplayAvailability.isAvailable) {
      return null;
    }
    return SecondaryCurrencyDisplay(
      primaryCurrency: currency,
      secondaryCurrency: secondaryCurrency,
      exchangeRate: exchangeRate,
    );
  }

  SuggestedPrice? suggestedPriceFor({
    required int costInCents,
    int unitFactor = 1,
  }) {
    if (!useDefaultProfitMargin || costInCents <= 0) {
      return null;
    }
    final factor = unitFactor <= 0 ? 1 : unitFactor;
    final priceInCents = (costInCents * (1 + defaultProfitMargin / 100))
        .round();
    return SuggestedPrice(
      costInCents: costInCents,
      priceInCents: priceInCents,
      marginPercent: defaultProfitMargin,
      unitFactor: factor,
    );
  }

  String? get companyLogoUrl {
    final value = settings.companyLogoUrl?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  AppTaxIdLabel? get taxIdLabelPreset => AppTaxIdLabel.tryFromLabel(taxIdLabel);

  // ── Objeto respuesta ────────────────────────────────────────────────────

  InvoiceDisplayConfig get invoiceDisplayConfig => InvoiceDisplayConfig(
    showItemsSummary: showInvoiceItemsSummary,
    showOrderCreator: showInvoiceOrderCreator,
  );
}
