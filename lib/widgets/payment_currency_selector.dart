import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

/// Configuración de monedas resuelta para un diálogo de cobro.
class PaymentCurrencySettings {
  final AppCurrency primaryCurrency;
  final AppCurrency secondaryCurrency;
  final double exchangeRate;
  final bool allowSecondaryCurrencyPayment;

  const PaymentCurrencySettings({
    required this.primaryCurrency,
    required this.secondaryCurrency,
    required this.exchangeRate,
    this.allowSecondaryCurrencyPayment = false,
  });

  bool get canUseDifferentSecondary =>
      allowSecondaryCurrencyPayment && secondaryCurrency != primaryCurrency;
  bool get hasValidExchangeRate => exchangeRate > 0;

  static PaymentCurrencySettings fromContext(BuildContext context) {
    try {
      final cubit = context.watch<AppSettingsCubit>();
      return PaymentCurrencySettings(
        primaryCurrency: cubit.currency,
        secondaryCurrency: cubit.secondaryCurrency,
        exchangeRate: cubit.exchangeRate,
        allowSecondaryCurrencyPayment: cubit.allowSecondaryCurrencyPayment,
      );
    } catch (_) {
      final secondaryConfig = NumberFormatter.secondaryCurrencyConfig;
      return PaymentCurrencySettings(
        primaryCurrency: NumberFormatter.currency,
        secondaryCurrency: secondaryConfig?.currency ?? AppCurrency.usd,
        exchangeRate: secondaryConfig?.exchangeRate ?? 0.0,
        allowSecondaryCurrencyPayment: false,
      );
    }
  }
}

/// Construye [PaymentDetail] cuando hay un monto recibido válido.
PaymentDetail? buildPaymentDetail({
  required bool useSecondary,
  required int tenderedCents,
  required int changePrimaryCents,
  required PaymentCurrencySettings settings,
}) {
  if (tenderedCents <= 0) return null;
  if (useSecondary) {
    if (!settings.hasValidExchangeRate) return null;
    return PaymentDetail(
      paidCurrency: settings.secondaryCurrency,
      tenderedAmount: tenderedCents,
      exchangeRate: settings.exchangeRate,
      changeAmount: changePrimaryCents > 0 ? changePrimaryCents : 0,
    );
  }
  return PaymentDetail(
    paidCurrency: settings.primaryCurrency,
    tenderedAmount: tenderedCents,
    exchangeRate: 1.0,
    changeAmount: changePrimaryCents > 0 ? changePrimaryCents : 0,
  );
}

/// Formatea el vuelto en moneda primaria y, si aplica, su equivalente en secundaria.
String formatPaymentChangeLabel(
  int changePrimaryCents, {
  required AppCurrency primaryCurrency,
  AppCurrency? secondaryCurrency,
  double? exchangeRate,
}) {
  final primaryFormatted = NumberFormatter.formatMoney(
    changePrimaryCents,
    primaryCurrency,
  );
  if (secondaryCurrency == null ||
      secondaryCurrency == primaryCurrency ||
      exchangeRate == null ||
      exchangeRate <= 0 ||
      changePrimaryCents <= 0) {
    return primaryFormatted;
  }
  final secondaryCents = NumberFormatter.convertPrimaryToSecondaryCents(
    changePrimaryCents,
    exchangeRate,
  );
  final secondaryFormatted = NumberFormatter.formatMoney(
    secondaryCents,
    secondaryCurrency,
  );
  return '$primaryFormatted ($secondaryFormatted)';
}

/// Selector de moneda de pago (primaria vs secundaria) con validación de tasa.
class PaymentCurrencySelector extends StatelessWidget {
  final PaymentCurrencySettings settings;
  final bool useSecondary;
  final ValueChanged<bool> onChanged;

  const PaymentCurrencySelector({
    super.key,
    required this.settings,
    required this.useSecondary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!settings.canUseDifferentSecondary) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: false,
              label: Text(
                '${settings.primaryCurrency.code} (${settings.primaryCurrency.symbol})',
              ),
              icon: const Icon(Icons.payments_outlined, size: 18),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text(
                '${settings.secondaryCurrency.code} (${settings.secondaryCurrency.symbol})',
              ),
              icon: const Icon(Icons.currency_exchange, size: 18),
            ),
          ],
          selected: {useSecondary},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
        if (useSecondary) ...[
          const SizedBox(height: 8),
          if (!settings.hasValidExchangeRate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay tasa de cambio configurada. Configúrala en Ajustes para cobrar en ${settings.secondaryCurrency.code}.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Tasa de cambio: 1 ${settings.secondaryCurrency.symbol} = ${settings.primaryCurrency.symbol}${settings.exchangeRate.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ],
    );
  }
}
