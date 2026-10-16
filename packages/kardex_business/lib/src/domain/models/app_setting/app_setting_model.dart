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
    required this.createdAt,
    this.updatedAt,
  });

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      id: json['id'] as String? ?? 'Default',
      useDefaultProfitMargin: json['useDefaultProfitMargin'] as bool? ?? false,
      defaultProfitMargin: (json['defaultProfitMargin'] as num?)?.toDouble() ?? 20.0,
      useExpirationDates: json['useExpirationDates'] as bool? ?? true,
      useOrders: json['useOrders'] as bool? ?? true,
      useQuotations: json['useQuotations'] as bool? ?? true,
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      alertMinStock: json['alertMinStock'] as bool? ?? true,
      defaultPaymentTermDays: json['defaultPaymentTermDays'] as int? ?? 30,
      useHoldSales: json['useHoldSales'] as bool? ?? true,
      useQuickProductSearch: json['useQuickProductSearch'] as bool? ?? false,
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
    return data;
  }
}
