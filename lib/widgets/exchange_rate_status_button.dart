import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/src/modules/settings/view/app_settings/currency_settings_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';

/// Botón compacto para AppBar que muestra la tasa de cambio vigente y permite
/// actualizarla rápidamente sin salir del menú ni de la terminal de venta.
class ExchangeRateStatusButton extends StatelessWidget {
  final bool compact;
  final VoidCallback? onUpdated;

  const ExchangeRateStatusButton({
    super.key,
    this.compact = false,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      bloc: getIt<AppSettingsCubit>(),
      builder: (context, _) {
        final cubit = getIt<AppSettingsCubit>();
        final settings = cubit.currentSettings;
        if (settings == null) return const SizedBox.shrink();

        final featureEnabled = settings.allowSecondaryCurrencyPayment || settings.showInvoiceTotalInSecondaryCurrency;
        if (!featureEnabled || settings.secondaryCurrency == settings.currency) {
          return const SizedBox.shrink();
        }

        final hasRate = settings.exchangeRate > 0;
        final color = hasRate ? Colors.teal.shade500 : AppThemeTokens.warning;
        final formattedRate = NumberFormat('#,##0.##', 'en_US').format(
          settings.exchangeRate,
        );

        final label = hasRate
            ? (compact
                  ? '${settings.currency.symbol}$formattedRate'
                  : '1 ${settings.secondaryCurrency.symbol} = ${settings.currency.symbol}$formattedRate')
            : (compact ? 'Sin T.C.' : 'Configurar T.C.');

        final tooltip = hasRate
            ? 'Tasa de cambio (${settings.secondaryCurrency.code} → ${settings.currency.code}). Toca para actualizar.'
            : 'Tasa de cambio no configurada. Toca para configurar.';

        return Tooltip(
          message: tooltip,
          child: Material(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final saved = await showCurrencySettingsDialog(
                  context,
                  primaryCurrency: settings.currency,
                  secondaryCurrency: settings.secondaryCurrency,
                  exchangeRate: settings.exchangeRate,
                );
                if (saved == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tasa de cambio actualizada'),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                onUpdated?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.currency_exchange_rounded, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
