import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_business/kardex_business.dart';

Future<bool?> showCurrencySettingsDialog(
  BuildContext context, {
  required AppCurrency primaryCurrency,
  required AppCurrency secondaryCurrency,
  required double exchangeRate,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _CurrencySettingsDialog(
      initialPrimaryCurrency: primaryCurrency,
      initialSecondaryCurrency: secondaryCurrency,
      initialExchangeRate: exchangeRate,
    ),
  );
}

class _CurrencySettingsDialog extends StatefulWidget {
  const _CurrencySettingsDialog({
    required this.initialPrimaryCurrency,
    required this.initialSecondaryCurrency,
    required this.initialExchangeRate,
  });

  final AppCurrency initialPrimaryCurrency;
  final AppCurrency initialSecondaryCurrency;
  final double initialExchangeRate;

  @override
  State<_CurrencySettingsDialog> createState() => _CurrencySettingsDialogState();
}

class _CurrencySettingsDialogState extends State<_CurrencySettingsDialog> {
  late AppCurrency _primaryCurrency;
  late AppCurrency _secondaryCurrency;
  late final TextEditingController _rateController;

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _primaryCurrency = widget.initialPrimaryCurrency;
    _secondaryCurrency = widget.initialSecondaryCurrency;
    if (_secondaryCurrency == _primaryCurrency) {
      _secondaryCurrency = _defaultSecondaryFor(_primaryCurrency);
    }
    _rateController = TextEditingController(
      text: _rateInputText(widget.initialExchangeRate),
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  AppCurrency _defaultSecondaryFor(AppCurrency primary) {
    return primary == AppCurrency.usd ? AppCurrency.nio : AppCurrency.usd;
  }

  List<AppCurrency> get _secondaryOptions =>
      AppCurrency.values.where((currency) => currency != _primaryCurrency).toList();

  double? get _parsedRate => double.tryParse(_rateController.text.trim());

  bool get _canSave {
    final rate = _parsedRate;
    return !_isSaving && rate != null && rate > 0 && _primaryCurrency != _secondaryCurrency;
  }

  String _rateInputText(double rate) {
    if (rate <= 0) return '';
    return rate.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _formatRate(double rate) {
    return NumberFormat('#,##0.####', 'en_US').format(rate);
  }

  void _onPrimaryChanged(AppCurrency? value) {
    if (value == null || value == _primaryCurrency) return;
    setState(() {
      _primaryCurrency = value;
      if (_secondaryCurrency == value) {
        _secondaryCurrency = _defaultSecondaryFor(value);
      }
      // La tasa anterior pertenece a otro par de monedas.
      _rateController.clear();
      _error = null;
    });
  }

  Future<void> _save() async {
    final rate = _parsedRate;

    if (rate == null || rate <= 0) {
      setState(() => _error = 'La tasa de cambio debe ser mayor que cero.');
      return;
    }

    if (_primaryCurrency == _secondaryCurrency) {
      setState(
        () => _error = 'La moneda secundaria debe ser diferente a la moneda principal.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final success = await getIt<AppSettingsCubit>().updateSettings(
      UpdateAppSetting(
        currency: _primaryCurrency,
        secondaryCurrency: _secondaryCurrency,
        exchangeRate: rate,
      ),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSaving = false;
        _error = 'No se pudo guardar la moneda y la tasa de cambio.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rate = _parsedRate;

    return AlertDialog(
      icon: Icon(
        Icons.currency_exchange_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 32,
      ),
      title: const Text(
        "Moneda y tasa de cambio",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Configura la moneda secundaria y la tasa informativa del sistema. "
                  "Estos valores no convierten montos ni modifican precios.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<AppCurrency>(
                  key: ValueKey("primary_${_primaryCurrency.code}"),
                  initialValue: _primaryCurrency,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Moneda principal",
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: AppCurrency.values
                      .map(
                        (currency) => DropdownMenuItem<AppCurrency>(
                          value: currency,
                          child: Text(
                            "${currency.symbol}  ·  ${currency.displayName}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving ? null : _onPrimaryChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppCurrency>(
                  key: ValueKey("secondary_${_secondaryCurrency.code}"),
                  initialValue: _secondaryCurrency,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Moneda secundaria",
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _secondaryOptions
                      .map(
                        (currency) => DropdownMenuItem<AppCurrency>(
                          value: currency,
                          child: Text(
                            "${currency.symbol}  ·  ${currency.displayName}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null && value != _secondaryCurrency) {
                            setState(() {
                              _secondaryCurrency = value;
                              // La tasa anterior pertenece a otro par de monedas.
                              _rateController.clear();
                              _error = null;
                            });
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rateController,
                  enabled: !_isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    const DecimalTextInputFormatter(decimalDigits: 4),
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    labelText: "Tasa de cambio",
                    prefixText: "1 ${_secondaryCurrency.symbol} = ",
                    suffixText: _primaryCurrency.symbol,
                    prefixIcon: const Icon(Icons.swap_horiz_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    helperText: "Ej. 1 ${_secondaryCurrency.symbol} = ${_primaryCurrency.symbol}36.62",
                  ),
                ),
                const SizedBox(height: 16),
                _buildPreview(rate),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text("Cancelar"),
        ),
        FilledButton.icon(
          onPressed: _canSave ? _save : null,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_isSaving ? "Guardando..." : "Guardar"),
        ),
      ],
    );
  }

  Widget _buildPreview(double? rate) {
    if (rate == null || rate <= 0) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Colors.orange.shade800,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Escribe una tasa mayor que cero para ver la equivalencia.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final primaryToSecondaryCents = (100000 / rate).round();
    final secondaryToPrimaryCents = (10000 * rate).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vista previa",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${NumberFormatter.formatMoney(100000, _primaryCurrency)} ≈ "
            "${NumberFormatter.formatMoney(primaryToSecondaryCents, _secondaryCurrency)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${NumberFormatter.formatMoney(10000, _secondaryCurrency)} ≈ "
            "${NumberFormatter.formatMoney(secondaryToPrimaryCents, _primaryCurrency)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "1 ${_secondaryCurrency.symbol} = ${_primaryCurrency.symbol}${_formatRate(rate)}",
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
