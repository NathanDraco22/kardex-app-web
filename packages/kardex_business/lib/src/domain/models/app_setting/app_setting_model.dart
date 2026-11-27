import 'app_currency.dart';
import 'app_tax_id_label.dart';

class AppSettingModel {
  final String id;
  final bool useDefaultProfitMargin;
  final double defaultProfitMargin;
  final bool useExpirationDates;
  final bool useOrders;
  final bool useQuotations;
  final bool allowNegativeStock;
  final bool alertMinStock;
  final int defaultPaymentTermDays;
  final bool useHoldSales;
  final bool useQuickProductSearch;
  final bool useShifts;
  final bool chargeConvertedOrdersToShift;
  final bool useDiscounts;
  final AppCurrency currency;
  final AppCurrency secondaryCurrency;
  final double exchangeRate;
  final bool showInvoiceTotalInSecondaryCurrency;
  final bool allowSecondaryCurrencyPayment;
  final bool showInvoiceItemsSummary;
  final bool showInvoiceOrderCreator;
  final String? companyLogoUrl;
  final String taxIdLabel;
  final int createdAt;
  final int? updatedAt;

  const AppSettingModel({
    required this.id,
    this.useDefaultProfitMargin = false,
    this.defaultProfitMargin = 20.0,
    this.useExpirationDates = true,
    this.useOrders = true,
    this.useQuotations = true,
    this.allowNegativeStock = false,
    this.alertMinStock = true,
    this.defaultPaymentTermDays = 30,
    this.useHoldSales = true,
    this.useQuickProductSearch = false,
    this.useShifts = false,
    this.chargeConvertedOrdersToShift = false,
    this.useDiscounts = false,
    this.currency = AppCurrency.nio,
    this.secondaryCurrency = AppCurrency.usd,
    this.exchangeRate = 0.0,
    this.showInvoiceTotalInSecondaryCurrency = false,
    this.allowSecondaryCurrencyPayment = false,
    this.showInvoiceItemsSummary = false,
    this.showInvoiceOrderCreator = false,
    this.companyLogoUrl,
    this.taxIdLabel = 'RUC',
    required this.createdAt,
    this.updatedAt,
  });

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      id: json['id'] as String? ?? 'Default',
      useDefaultProfitMargin: json['useDefaultProfitMargin'] as bool? ?? false,
      defaultProfitMargin:
          (json['defaultProfitMargin'] as num?)?.toDouble() ?? 20.0,
      useExpirationDates: json['useExpirationDates'] as bool? ?? true,
      useOrders: json['useOrders'] as bool? ?? true,
      useQuotations: json['useQuotations'] as bool? ?? true,
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      alertMinStock: json['alertMinStock'] as bool? ?? true,
      defaultPaymentTermDays: json['defaultPaymentTermDays'] as int? ?? 30,
      useHoldSales: json['useHoldSales'] as bool? ?? true,
      useQuickProductSearch: json['useQuickProductSearch'] as bool? ?? false,
      useShifts: json['useShifts'] as bool? ?? false,
      chargeConvertedOrdersToShift:
          json['chargeConvertedOrdersToShift'] as bool? ?? false,
      useDiscounts: json['useDiscounts'] as bool? ?? false,
      currency: AppCurrency.fromCode(json['currency'] as String?),
      secondaryCurrency: AppCurrency.fromCode(
        json['secondaryCurrency'] as String?,
        fallback: AppCurrency.usd,
      ),
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 0.0,
      showInvoiceTotalInSecondaryCurrency:
          json['showInvoiceTotalInSecondaryCurrency'] as bool? ?? false,
      allowSecondaryCurrencyPayment:
          json['allowSecondaryCurrencyPayment'] as bool? ?? false,
      showInvoiceItemsSummary:
          json['showInvoiceItemsSummary'] as bool? ?? false,
      showInvoiceOrderCreator:
          json['showInvoiceOrderCreator'] as bool? ?? false,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      taxIdLabel: AppTaxIdLabel.normalize(json['taxIdLabel'] as String?),
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'useDefaultProfitMargin': useDefaultProfitMargin,
      'defaultProfitMargin': defaultProfitMargin,
      'useExpirationDates': useExpirationDates,
      'useOrders': useOrders,
      'useQuotations': useQuotations,
      'allowNegativeStock': allowNegativeStock,
      'alertMinStock': alertMinStock,
      'defaultPaymentTermDays': defaultPaymentTermDays,
      'useHoldSales': useHoldSales,
      'useQuickProductSearch': useQuickProductSearch,
      'useShifts': useShifts,
      'chargeConvertedOrdersToShift': chargeConvertedOrdersToShift,
      'useDiscounts': useDiscounts,
      'currency': currency.code,
      'secondaryCurrency': secondaryCurrency.code,
      'exchangeRate': exchangeRate,
      'showInvoiceTotalInSecondaryCurrency':
          showInvoiceTotalInSecondaryCurrency,
      'allowSecondaryCurrencyPayment': allowSecondaryCurrencyPayment,
      'showInvoiceItemsSummary': showInvoiceItemsSummary,
      'showInvoiceOrderCreator': showInvoiceOrderCreator,
      'companyLogoUrl': companyLogoUrl,
      'taxIdLabel': taxIdLabel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppSettingModel copyWith({
    String? id,
    bool? useDefaultProfitMargin,
    double? defaultProfitMargin,
    bool? useExpirationDates,
    bool? useOrders,
    bool? useQuotations,
    bool? allowNegativeStock,
    bool? alertMinStock,
    int? defaultPaymentTermDays,
    bool? useHoldSales,
    bool? useQuickProductSearch,
    bool? useShifts,
    bool? chargeConvertedOrdersToShift,
    bool? useDiscounts,
    AppCurrency? currency,
    AppCurrency? secondaryCurrency,
    double? exchangeRate,
    bool? showInvoiceTotalInSecondaryCurrency,
    bool? allowSecondaryCurrencyPayment,
    bool? showInvoiceItemsSummary,
    bool? showInvoiceOrderCreator,
    String? companyLogoUrl,
    String? taxIdLabel,
    int? createdAt,
    int? updatedAt,
  }) {
    return AppSettingModel(
      id: id ?? this.id,
      useDefaultProfitMargin:
          useDefaultProfitMargin ?? this.useDefaultProfitMargin,
      defaultProfitMargin: defaultProfitMargin ?? this.defaultProfitMargin,
      useExpirationDates: useExpirationDates ?? this.useExpirationDates,
      useOrders: useOrders ?? this.useOrders,
      useQuotations: useQuotations ?? this.useQuotations,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      alertMinStock: alertMinStock ?? this.alertMinStock,
      defaultPaymentTermDays:
          defaultPaymentTermDays ?? this.defaultPaymentTermDays,
      useHoldSales: useHoldSales ?? this.useHoldSales,
      useQuickProductSearch:
          useQuickProductSearch ?? this.useQuickProductSearch,
      useShifts: useShifts ?? this.useShifts,
      chargeConvertedOrdersToShift:
          chargeConvertedOrdersToShift ?? this.chargeConvertedOrdersToShift,
      useDiscounts: useDiscounts ?? this.useDiscounts,
      currency: currency ?? this.currency,
      secondaryCurrency: secondaryCurrency ?? this.secondaryCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      showInvoiceTotalInSecondaryCurrency:
          showInvoiceTotalInSecondaryCurrency ??
          this.showInvoiceTotalInSecondaryCurrency,
      allowSecondaryCurrencyPayment:
          allowSecondaryCurrencyPayment ??
          this.allowSecondaryCurrencyPayment,
      showInvoiceItemsSummary:
          showInvoiceItemsSummary ?? this.showInvoiceItemsSummary,
      showInvoiceOrderCreator:
          showInvoiceOrderCreator ?? this.showInvoiceOrderCreator,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      taxIdLabel: taxIdLabel ?? this.taxIdLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UpdateAppSetting {
  final bool? useDefaultProfitMargin;
  final double? defaultProfitMargin;
  final bool? useExpirationDates;
  final bool? useOrders;
  final bool? useQuotations;
  final bool? allowNegativeStock;
  final bool? alertMinStock;
  final int? defaultPaymentTermDays;
  final bool? useHoldSales;
  final bool? useQuickProductSearch;
  final bool? useShifts;
  final bool? chargeConvertedOrdersToShift;
  final bool? useDiscounts;
  final AppCurrency? currency;
  final AppCurrency? secondaryCurrency;
  final double? exchangeRate;
  final bool? showInvoiceTotalInSecondaryCurrency;
  final bool? allowSecondaryCurrencyPayment;
  final bool? showInvoiceItemsSummary;
  final bool? showInvoiceOrderCreator;
  final String? companyLogoUrl;
  final String? taxIdLabel;

  const UpdateAppSetting({
    this.useDefaultProfitMargin,
    this.defaultProfitMargin,
    this.useExpirationDates,
    this.useOrders,
    this.useQuotations,
    this.allowNegativeStock,
    this.alertMinStock,
    this.defaultPaymentTermDays,
    this.useHoldSales,
    this.useQuickProductSearch,
    this.useShifts,
    this.chargeConvertedOrdersToShift,
    this.useDiscounts,
    this.currency,
    this.secondaryCurrency,
    this.exchangeRate,
    this.showInvoiceTotalInSecondaryCurrency,
    this.allowSecondaryCurrencyPayment,
    this.showInvoiceItemsSummary,
    this.showInvoiceOrderCreator,
    this.companyLogoUrl,
    this.taxIdLabel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (useDefaultProfitMargin != null) {
      data['useDefaultProfitMargin'] = useDefaultProfitMargin;
    }
    if (defaultProfitMargin != null) {
      data['defaultProfitMargin'] = defaultProfitMargin;
    }
    if (useExpirationDates != null) {
      data['useExpirationDates'] = useExpirationDates;
    }
    if (useOrders != null) {
      data['useOrders'] = useOrders;
    }
    if (useQuotations != null) {
      data['useQuotations'] = useQuotations;
    }
    if (allowNegativeStock != null) {
      data['allowNegativeStock'] = allowNegativeStock;
    }
    if (alertMinStock != null) {
      data['alertMinStock'] = alertMinStock;
    }
    if (defaultPaymentTermDays != null) {
      data['defaultPaymentTermDays'] = defaultPaymentTermDays;
    }
    if (useHoldSales != null) {
      data['useHoldSales'] = useHoldSales;
    }
    if (useQuickProductSearch != null) {
      data['useQuickProductSearch'] = useQuickProductSearch;
    }
    if (useShifts != null) {
      data['useShifts'] = useShifts;
    }
    if (chargeConvertedOrdersToShift != null) {
      data['chargeConvertedOrdersToShift'] = chargeConvertedOrdersToShift;
    }
    if (useDiscounts != null) {
      data['useDiscounts'] = useDiscounts;
    }
    if (currency != null) {
      data['currency'] = currency!.code;
    }
    if (secondaryCurrency != null) {
      data['secondaryCurrency'] = secondaryCurrency!.code;
    }
    if (exchangeRate != null) {
      data['exchangeRate'] = exchangeRate;
    }
    if (showInvoiceTotalInSecondaryCurrency != null) {
      data['showInvoiceTotalInSecondaryCurrency'] =
          showInvoiceTotalInSecondaryCurrency;
    }
    if (allowSecondaryCurrencyPayment != null) {
      data['allowSecondaryCurrencyPayment'] = allowSecondaryCurrencyPayment;
    }
    if (showInvoiceItemsSummary != null) {
      data['showInvoiceItemsSummary'] = showInvoiceItemsSummary;
    }
    if (showInvoiceOrderCreator != null) {
      data['showInvoiceOrderCreator'] = showInvoiceOrderCreator;
    }
    if (companyLogoUrl != null) {
      data['companyLogoUrl'] = companyLogoUrl;
    }
    if (taxIdLabel != null && taxIdLabel!.trim().isNotEmpty) {
      data['taxIdLabel'] = taxIdLabel!.trim();
    }
    return data;
  }
}
