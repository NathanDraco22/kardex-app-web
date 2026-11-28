import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

AppSettingsPolicy _policy({
  bool useShifts = false,
  bool chargeConvertedOrdersToShift = false,
  bool requireShiftForConvertedOrders = false,
  bool allowSecondaryCurrencyPayment = false,
  bool showInvoiceTotalInSecondaryCurrency = false,
  bool useAbonoReceivedAmount = false,
  AppCurrency currency = AppCurrency.nio,
  AppCurrency secondaryCurrency = AppCurrency.usd,
  double exchangeRate = 0.0,
  bool useDefaultProfitMargin = false,
  double defaultProfitMargin = 20.0,
  bool useClientPreferredPrices = true,
  String taxIdLabel = 'RUC',
  String? companyLogoUrl,
}) {
  return AppSettingsPolicy(
    AppSettingModel(
      id: 'test',
      createdAt: 0,
      useShifts: useShifts,
      chargeConvertedOrdersToShift: chargeConvertedOrdersToShift,
      requireShiftForConvertedOrders: requireShiftForConvertedOrders,
      allowSecondaryCurrencyPayment: allowSecondaryCurrencyPayment,
      showInvoiceTotalInSecondaryCurrency: showInvoiceTotalInSecondaryCurrency,
      useAbonoReceivedAmount: useAbonoReceivedAmount,
      currency: currency,
      secondaryCurrency: secondaryCurrency,
      exchangeRate: exchangeRate,
      useDefaultProfitMargin: useDefaultProfitMargin,
      defaultProfitMargin: defaultProfitMargin,
      useClientPreferredPrices: useClientPreferredPrices,
      taxIdLabel: taxIdLabel,
      companyLogoUrl: companyLogoUrl,
    ),
  );
}

void main() {
  group('valores por defecto', () {
    test('usa AppSettingModel.defaults cuando no hay configuración', () {
      const policy = AppSettingsPolicy();

      expect(policy.currency, AppCurrency.nio);
      expect(policy.secondaryCurrency, AppCurrency.usd);
      expect(policy.exchangeRate, 0);
      expect(policy.defaultPaymentTermDays, 30);
      expect(policy.useShifts, isFalse);
      expect(policy.useAbonoReceivedAmount, isFalse);
      expect(
        policy.abonoPaymentPolicy.mode,
        AbonoCaptureMode.singleAmount,
      );
      expect(policy.hasExchangeRate, isFalse);
      expect(policy.hasCompanyLogo, isFalse);
      expect(policy.taxIdLabel, 'RUC');
      expect(policy.taxIdLabelPreset, AppTaxIdLabel.ruc);
      expect(policy.convertedOrderShiftPolicy, ConvertedOrderShiftPolicy.never);
      expect(policy.secondaryCurrencyPaymentTerms, isNull);
      expect(policy.invoiceSecondaryCurrencyDisplay, isNull);
      expect(policy.suggestedPriceFor(costInCents: 1000), isNull);
    });
  });

  group('captura de abonos', () {
    test('AppSettingModel y UpdateAppSetting serializan la bandera', () {
      final legacy = AppSettingModel.fromJson({});
      expect(legacy.useAbonoReceivedAmount, isFalse);

      final loaded = AppSettingModel.fromJson({
        'useAbonoReceivedAmount': true,
      });
      expect(loaded.useAbonoReceivedAmount, isTrue);
      expect(loaded.toJson()['useAbonoReceivedAmount'], isTrue);

      expect(
        const UpdateAppSetting(useAbonoReceivedAmount: true).toJson(),
        {'useAbonoReceivedAmount': true},
      );
    });

    test('la bandera construye la policy de dos montos', () {
      final policy = _policy(useAbonoReceivedAmount: true);

      expect(policy.useAbonoReceivedAmount, isTrue);
      expect(
        policy.abonoPaymentPolicy.mode,
        AbonoCaptureMode.appliedAndReceived,
      );
    });

    test('sin bandera conserva el modo de un solo monto', () {
      final policy = _policy();

      expect(policy.useAbonoReceivedAmount, isFalse);
      expect(
        policy.abonoPaymentPolicy.mode,
        AbonoCaptureMode.singleAmount,
      );
    });
  });

  group('ConvertedOrderShiftPolicy', () {
    test('never cuando los turnos están apagados', () {
      final policy = _policy(
        useShifts: false,
        chargeConvertedOrdersToShift: true,
        requireShiftForConvertedOrders: true,
      );

      expect(policy.convertedOrderShiftPolicy, ConvertedOrderShiftPolicy.never);
      expect(policy.convertedOrderShiftPolicy.linkToShift, isFalse);
      expect(policy.convertedOrderShiftPolicy.requiresOpenShift, isFalse);
    });

    test('never cuando no se carga a turno', () {
      final policy = _policy(
        useShifts: true,
        chargeConvertedOrdersToShift: false,
        requireShiftForConvertedOrders: true,
      );

      expect(policy.convertedOrderShiftPolicy, ConvertedOrderShiftPolicy.never);
    });

    test('optional cuando hay turno abierto pero no se exige', () {
      final policy = _policy(
        useShifts: true,
        chargeConvertedOrdersToShift: true,
        requireShiftForConvertedOrders: false,
      );

      expect(
        policy.convertedOrderShiftPolicy,
        ConvertedOrderShiftPolicy.optional,
      );
      expect(policy.convertedOrderShiftPolicy.linkToShift, isTrue);
      expect(policy.convertedOrderShiftPolicy.requiresOpenShift, isFalse);
    });

    test('required cuando se exige turno abierto', () {
      final policy = _policy(
        useShifts: true,
        chargeConvertedOrdersToShift: true,
        requireShiftForConvertedOrders: true,
      );

      expect(
        policy.convertedOrderShiftPolicy,
        ConvertedOrderShiftPolicy.required,
      );
      expect(policy.convertedOrderShiftPolicy.linkToShift, isTrue);
      expect(policy.convertedOrderShiftPolicy.requiresOpenShift, isTrue);
    });
  });

  group('moneda secundaria', () {
    test('disabled cuando la función está apagada', () {
      final policy = _policy(
        allowSecondaryCurrencyPayment: false,
        exchangeRate: 36,
      );

      expect(
        policy.paymentAvailability,
        SecondaryCurrencyAvailability.disabled,
      );
      expect(policy.offersSecondaryCurrencyPayment, isFalse);
      expect(policy.secondaryCurrencyPaymentTerms, isNull);
    });

    test('sameCurrency cuando la moneda secundaria es la principal', () {
      final policy = _policy(
        allowSecondaryCurrencyPayment: true,
        currency: AppCurrency.nio,
        secondaryCurrency: AppCurrency.nio,
        exchangeRate: 36,
      );

      expect(
        policy.paymentAvailability,
        SecondaryCurrencyAvailability.sameCurrency,
      );
      expect(policy.offersSecondaryCurrencyPayment, isFalse);
      expect(policy.secondaryCurrencyPaymentTerms, isNull);
    });

    test('missingExchangeRate cuando falta la tasa', () {
      final policy = _policy(
        allowSecondaryCurrencyPayment: true,
        exchangeRate: 0,
      );

      expect(
        policy.paymentAvailability,
        SecondaryCurrencyAvailability.missingExchangeRate,
      );
      expect(policy.offersSecondaryCurrencyPayment, isTrue);
      expect(policy.hasExchangeRate, isFalse);
      expect(policy.secondaryCurrencyPaymentTerms, isNull);
    });

    test('available con moneda distinta y tasa válida', () {
      final policy = _policy(
        allowSecondaryCurrencyPayment: true,
        exchangeRate: 36,
      );

      expect(
        policy.paymentAvailability,
        SecondaryCurrencyAvailability.available,
      );
      expect(policy.secondaryCurrencyPaymentTerms, isNotNull);
      expect(policy.secondaryCurrencyPaymentTerms!.primaryCurrency, AppCurrency.nio);
      expect(policy.secondaryCurrencyPaymentTerms!.secondaryCurrency, AppCurrency.usd);
      expect(policy.secondaryCurrencyPaymentTerms!.exchangeRate, 36);
    });

    test('invoiceDisplayAvailability sigue las mismas reglas', () {
      expect(
        _policy(showInvoiceTotalInSecondaryCurrency: false).invoiceDisplayAvailability,
        SecondaryCurrencyAvailability.disabled,
      );
      expect(
        _policy(
          showInvoiceTotalInSecondaryCurrency: true,
          exchangeRate: 0,
        ).invoiceDisplayAvailability,
        SecondaryCurrencyAvailability.missingExchangeRate,
      );
      expect(
        _policy(
          showInvoiceTotalInSecondaryCurrency: true,
          exchangeRate: 36,
        ).invoiceDisplayAvailability,
        SecondaryCurrencyAvailability.available,
      );
    });

    test('invoiceSecondaryCurrencyDisplay solo existe si puede mostrarse', () {
      final disabled = _policy(showInvoiceTotalInSecondaryCurrency: false);
      final missingRate = _policy(
        showInvoiceTotalInSecondaryCurrency: true,
        exchangeRate: 0,
      );
      final available = _policy(
        showInvoiceTotalInSecondaryCurrency: true,
        exchangeRate: 36,
      );

      expect(disabled.invoiceSecondaryCurrencyDisplay, isNull);
      expect(missingRate.invoiceSecondaryCurrencyDisplay, isNull);
      expect(available.invoiceSecondaryCurrencyDisplay, isNotNull);
      expect(available.invoiceSecondaryCurrencyDisplay!.secondaryCurrency, AppCurrency.usd);
      expect(available.invoiceSecondaryCurrencyDisplay!.exchangeRate, 36);
    });

    test('showsExchangeRateStatus requiere una función activa y monedas distintas', () {
      expect(
        _policy().showsExchangeRateStatus,
        isFalse,
      );
      expect(
        _policy(allowSecondaryCurrencyPayment: true).showsExchangeRateStatus,
        isTrue,
      );
      expect(
        _policy(showInvoiceTotalInSecondaryCurrency: true).showsExchangeRateStatus,
        isTrue,
      );
      expect(
        _policy(
          allowSecondaryCurrencyPayment: true,
          currency: AppCurrency.nio,
          secondaryCurrency: AppCurrency.nio,
        ).showsExchangeRateStatus,
        isFalse,
      );
    });
  });

  group('margen sugerido', () {
    test('es nulo cuando el margen automático está apagado', () {
      final policy = _policy(useDefaultProfitMargin: false);
      expect(policy.suggestedPriceFor(costInCents: 1000), isNull);
    });

    test('es nulo cuando el costo no es positivo', () {
      final policy = _policy(useDefaultProfitMargin: true);
      expect(policy.suggestedPriceFor(costInCents: 0), isNull);
      expect(policy.suggestedPriceFor(costInCents: -100), isNull);
    });

    test('calcula el precio con el margen configurado', () {
      final policy = _policy(
        useDefaultProfitMargin: true,
        defaultProfitMargin: 20,
      );
      final suggestion = policy.suggestedPriceFor(costInCents: 1000);

      expect(suggestion, isNotNull);
      expect(suggestion!.costInCents, 1000);
      expect(suggestion.priceInCents, 1200);
      expect(suggestion.marginPercent, 20);
      expect(suggestion.unitFactor, 1);
      expect(suggestion.totalPriceInCents, 1200);
      expect(suggestion.totalCostInCents, 1000);
    });

    test('aplica el factor de la unidad seleccionada', () {
      final policy = _policy(
        useDefaultProfitMargin: true,
        defaultProfitMargin: 20,
      );
      final suggestion = policy.suggestedPriceFor(
        costInCents: 1000,
        unitFactor: 5,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.unitFactor, 5);
      expect(suggestion.totalPriceInCents, 6000);
      expect(suggestion.totalCostInCents, 5000);
    });

    test('normaliza un factor inválido a 1', () {
      final policy = _policy(
        useDefaultProfitMargin: true,
        defaultProfitMargin: 20,
      );
      final suggestion = policy.suggestedPriceFor(
        costInCents: 1000,
        unitFactor: 0,
      );

      expect(suggestion!.unitFactor, 1);
      expect(suggestion.totalPriceInCents, 1200);
    });

    test('redondea el precio al centavo más cercano', () {
      final policy = _policy(
        useDefaultProfitMargin: true,
        defaultProfitMargin: 20,
      );
      final suggestion = policy.suggestedPriceFor(costInCents: 333);

      expect(suggestion!.priceInCents, 400);
    });
  });

  group('visualización de factura', () {
    test('expone el objeto respuesta con las dos banderas', () {
      final policy = _policy();
      expect(policy.invoiceDisplayConfig.showItemsSummary, isFalse);
      expect(policy.invoiceDisplayConfig.showOrderCreator, isFalse);
    });

    test('refleja las banderas activas', () {
      const policy = AppSettingsPolicy(
        AppSettingModel(
          id: 'test',
          createdAt: 0,
          showInvoiceItemsSummary: true,
          showInvoiceOrderCreator: true,
        ),
      );

      expect(policy.invoiceDisplayConfig.showItemsSummary, isTrue);
      expect(policy.invoiceDisplayConfig.showOrderCreator, isTrue);
    });
  });

  group('precios preferenciales de clientes', () {
    test('la bandera está activa por defecto', () {
      const policy = AppSettingsPolicy();

      expect(policy.useClientPreferredPrices, isTrue);
      expect(AppSettingModel.defaults.useClientPreferredPrices, isTrue);
      expect(
        AppSettingModel.fromJson({'id': 'legacy', 'createdAt': 0}).useClientPreferredPrices,
        isTrue,
      );
    });

    test('AppSettingModel serializa la bandera', () {
      const settings = AppSettingModel(
        id: 'test',
        createdAt: 0,
        useClientPreferredPrices: false,
      );

      expect(settings.toJson()['useClientPreferredPrices'], isFalse);
      expect(
        settings.copyWith(useClientPreferredPrices: true).useClientPreferredPrices,
        isTrue,
      );
    });

    test('UpdateAppSetting envía la bandera solo cuando cambia', () {
      expect(const UpdateAppSetting().toJson(), isEmpty);
      expect(
        const UpdateAppSetting(useClientPreferredPrices: false).toJson(),
        {'useClientPreferredPrices': false},
      );
    });

    test('la policy expone la preferencia según la bandera', () {
      final active = _policy(useClientPreferredPrices: true);
      final inactive = _policy(useClientPreferredPrices: false);

      expect(active.useClientPreferredPrices, isTrue);
      expect(inactive.useClientPreferredPrices, isFalse);
    });
  });

  group('identidad y etiqueta tributaria', () {
    test('normaliza el logo y expone si existe', () {
      final withLogo = _policy(companyLogoUrl: '  https://cdn/logo.png  ');
      final withoutLogo = _policy(companyLogoUrl: '   ');

      expect(withLogo.companyLogoUrl, 'https://cdn/logo.png');
      expect(withLogo.hasCompanyLogo, isTrue);
      expect(withoutLogo.companyLogoUrl, isNull);
      expect(withoutLogo.hasCompanyLogo, isFalse);
    });

    test('detecta el preset tributario o lo deja nulo si es personalizado', () {
      expect(_policy(taxIdLabel: 'NIT').taxIdLabelPreset, AppTaxIdLabel.nit);
      expect(_policy(taxIdLabel: 'Tax ID').taxIdLabelPreset, isNull);
      expect(_policy(taxIdLabel: '   ').taxIdLabel, 'RUC');
    });
  });
}
