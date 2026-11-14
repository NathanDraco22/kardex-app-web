import 'dart:typed_data';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/tools/uploaders/image_uploader.dart';
import 'currency_settings_dialog.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppSettingsView();
  }
}

class _AppSettingsView extends StatefulWidget {
  const _AppSettingsView();

  @override
  State<_AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<_AppSettingsView> {
  late final TextEditingController _profitMarginController;
  late final TextEditingController _paymentTermController;

  bool _initialized = false;
  String? _companyLogoUrl;
  Uint8List? _pendingCompanyLogoBytes;
  bool _isSavingCompanyLogo = false;
  bool _useDefaultProfitMargin = false;
  bool _useExpirationDates = true;
  bool _useOrders = true;
  bool _useQuotations = true;
  bool _allowNegativeStock = false;
  bool _alertMinStock = true;
  bool _useHoldSales = true;
  bool _useQuickProductSearch = false;
  bool _useShifts = false;
  AppCurrency _currency = AppCurrency.nio;
  AppCurrency _secondaryCurrency = AppCurrency.usd;
  double _exchangeRate = 0.0;
  bool _showInvoiceTotalInSecondaryCurrency = false;

  @override
  void initState() {
    super.initState();
    _profitMarginController = TextEditingController();
    _paymentTermController = TextEditingController();

    final cubit = getIt<AppSettingsCubit>();
    if (cubit.currentSettings != null) {
      _syncWithSettings(cubit.currentSettings!);
    } else if (cubit.state is! AppSettingsLoaded) {
      cubit.loadSettings();
    }
  }

  @override
  void dispose() {
    _profitMarginController.dispose();
    _paymentTermController.dispose();
    super.dispose();
  }

  void _syncWithSettings(AppSettingModel settings) {
    if (!_initialized) {
      _useDefaultProfitMargin = settings.useDefaultProfitMargin;
      _profitMarginController.text = settings.defaultProfitMargin.toString();
      _useExpirationDates = settings.useExpirationDates;
      _useOrders = settings.useOrders;
      _useQuotations = settings.useQuotations;
      _allowNegativeStock = settings.allowNegativeStock;
      _alertMinStock = settings.alertMinStock;
      _paymentTermController.text = settings.defaultPaymentTermDays.toString();
      _useHoldSales = settings.useHoldSales;
      _useQuickProductSearch = settings.useQuickProductSearch;
      _useShifts = settings.useShifts;
      _showInvoiceTotalInSecondaryCurrency = settings.showInvoiceTotalInSecondaryCurrency;
      _initialized = true;
    }

    // La moneda y la tasa se guardan desde su propio diálogo, por lo que
    // siempre deben reflejar el estado vivo del Cubit.
    _currency = settings.currency;
    _secondaryCurrency = settings.secondaryCurrency;
    _exchangeRate = settings.exchangeRate;
    _companyLogoUrl = settings.companyLogoUrl;
  }

  static const double _fallbackProfitMargin = 20.0;
  static const int _fallbackPaymentTerm = 30;

  double get _profitMarginValue =>
      double.tryParse(_profitMarginController.text.trim()) ?? _fallbackProfitMargin;

  int get _paymentTermValue =>
      int.tryParse(_paymentTermController.text.trim()) ?? _fallbackPaymentTerm;

  /// Fuerza el rebuild del punto ámbar del AppBar al escribir en los campos
  /// numéricos. Se invoca desde `onChanged`, no desde listeners del controller,
  /// para no disparar `setState` cuando `_syncWithSettings` asigna texto durante
  /// el build.
  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  /// Compara solo los parámetros que guarda el botón "Guardar" del AppBar.
  /// Moneda, tasa y logo se guardan de inmediato en su propio flujo.
  bool _hasUnsavedChanges(AppSettingModel settings) {
    return _useDefaultProfitMargin != settings.useDefaultProfitMargin ||
        _profitMarginValue != settings.defaultProfitMargin ||
        _useExpirationDates != settings.useExpirationDates ||
        _useOrders != settings.useOrders ||
        _useQuotations != settings.useQuotations ||
        _allowNegativeStock != settings.allowNegativeStock ||
        _alertMinStock != settings.alertMinStock ||
        _paymentTermValue != settings.defaultPaymentTermDays ||
        _useHoldSales != settings.useHoldSales ||
        _useQuickProductSearch != settings.useQuickProductSearch ||
        _useShifts != settings.useShifts ||
        _showInvoiceTotalInSecondaryCurrency != settings.showInvoiceTotalInSecondaryCurrency;
  }

  Future<void> _saveSettings() async {
    final profitMargin = _profitMarginValue;
    final paymentTerm = _paymentTermValue;

    final update = UpdateAppSetting(
      useDefaultProfitMargin: _useDefaultProfitMargin,
      defaultProfitMargin: profitMargin,
      useExpirationDates: _useExpirationDates,
      useOrders: _useOrders,
      useQuotations: _useQuotations,
      allowNegativeStock: _allowNegativeStock,
      alertMinStock: _alertMinStock,
      defaultPaymentTermDays: paymentTerm,
      useHoldSales: _useHoldSales,
      useQuickProductSearch: _useQuickProductSearch,
      useShifts: _useShifts,
      showInvoiceTotalInSecondaryCurrency: _showInvoiceTotalInSecondaryCurrency,
    );

    final success = await getIt<AppSettingsCubit>().updateSettings(update);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Configuraciones guardadas exitosamente"),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al guardar la configuración"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openCurrencySettingsDialog() async {
    final saved = await showCurrencySettingsDialog(
      context,
      primaryCurrency: _currency,
      secondaryCurrency: _secondaryCurrency,
      exchangeRate: _exchangeRate,
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Moneda y tasa de cambio actualizadas"),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSettingsSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ImageProvider? get _companyLogoImageProvider {
    final pendingBytes = _pendingCompanyLogoBytes;
    if (pendingBytes != null && pendingBytes.isNotEmpty) {
      return MemoryImage(pendingBytes);
    }

    final url = (_companyLogoUrl ?? '').trim();
    if (url.isEmpty) return null;

    return CachedNetworkImageProvider(
      url,
      cacheManager: AppImageCacheManager.instance,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
    );
  }

  Future<void> _pickCompanyLogo() async {
    if (_isSavingCompanyLogo) return;

    final intent = await showImageSelectorDialog(
      context: context,
      initialImage: _companyLogoImageProvider,
      encodeAsPng: true,
    );

    if (intent == null || !mounted) return;

    switch (intent) {
      case NewImageIntent(:final bytes):
        await _uploadCompanyLogo(bytes);
      case ChangeImageIntent(:final bytes):
        await _uploadCompanyLogo(bytes);
      case DeleteImageIntent():
        await _clearCompanyLogo(confirm: false);
    }
  }

  Future<void> _uploadCompanyLogo(Uint8List bytes) async {
    setState(() {
      _pendingCompanyLogoBytes = bytes;
      _isSavingCompanyLogo = true;
    });

    try {
      final uploadFileName = 'company_logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final url = await ImageUploader.uploadImage(
        bytes: bytes,
        fileName: uploadFileName,
        mediaType: 'image/png',
      );

      final success = await getIt<AppSettingsCubit>().updateSettings(
        UpdateAppSetting(companyLogoUrl: url),
      );

      if (!mounted) return;

      if (success) {
        setState(() => _companyLogoUrl = url);
        _showSettingsSnackBar("Logo de la empresa actualizado");
      } else {
        _showSettingsSnackBar(
          "No se pudo guardar el logo. Inténtalo de nuevo.",
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSettingsSnackBar(
          "No se pudo subir la imagen. Inténtalo de nuevo.",
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _pendingCompanyLogoBytes = null;
          _isSavingCompanyLogo = false;
        });
      }
    }
  }

  Future<void> _removeCompanyLogo() => _clearCompanyLogo(confirm: true);

  Future<void> _clearCompanyLogo({required bool confirm}) async {
    if (confirm) {
      final confirmed = await DialogManager.confirmActionDialog(
        context,
        "¿Quitar el logo de la empresa?",
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _isSavingCompanyLogo = true);

    try {
      final success = await getIt<AppSettingsCubit>().updateSettings(
        const UpdateAppSetting(companyLogoUrl: ""),
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _companyLogoUrl = "";
          _pendingCompanyLogoBytes = null;
        });
        _showSettingsSnackBar("Logo de la empresa eliminado");
      } else {
        _showSettingsSnackBar(
          "No se pudo quitar el logo. Inténtalo de nuevo.",
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSettingsSnackBar(
          "No se pudo quitar el logo. Inténtalo de nuevo.",
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingCompanyLogo = false);
      }
    }
  }

  String _formatExchangeRate(double rate) {
    if (rate <= 0) return '—';
    return NumberFormat('#,##0.####', 'en_US').format(rate);
  }

  Widget _buildCurrencySummaryTile({required bool isSaving}) {
    final hasRate = _exchangeRate > 0;
    final rateLabel = hasRate
        ? '1 ${_secondaryCurrency.symbol} = ${_currency.symbol}${_formatExchangeRate(_exchangeRate)}'
        : 'Tasa de cambio sin configurar';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.teal.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isSaving ? null : _openCurrencySettingsDialog,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Moneda y tasa de cambio",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.teal.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _CurrencyBadge(currency: _currency),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        _CurrencyBadge(currency: _secondaryCurrency),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rateLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasRate ? Colors.teal.shade900 : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceSecondaryTotalSwitch({required bool isSaving}) {
    final hasRate = _exchangeRate > 0;
    final isEnabled = _showInvoiceTotalInSecondaryCurrency;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            secondary: Icon(
              Icons.receipt_long_rounded,
              color: Colors.teal.shade700,
            ),
            title: Text(
              "Mostrar total de facturas en moneda secundaria (${_secondaryCurrency.code})",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Agrega el equivalente en ${_secondaryCurrency.symbol} después del total final en el visor, PDF y ticket.",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            value: isEnabled,
            onChanged: isSaving
                ? null
                : (value) {
                    setState(() {
                      _showInvoiceTotalInSecondaryCurrency = value;
                    });
                  },
          ),
          if (isEnabled && !hasRate)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Configura una tasa de cambio mayor que cero para que el total secundario aparezca en las facturas.",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogoCard({required bool isSaving}) {
    final hasLogo = (_companyLogoUrl ?? '').trim().isNotEmpty || _pendingCompanyLogoBytes != null;
    final isBusy = _isSavingCompanyLogo;
    final isDisabled = isSaving || isBusy;

    final preview = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: CompanyLogo(
            imageUrl: _companyLogoUrl,
            localBytes: _pendingCompanyLogoBytes,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(10),
            fallback: Center(
              child: Icon(
                Icons.business_rounded,
                size: 42,
                color: Colors.grey.shade400,
              ),
            ),
            placeholder: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        if (isBusy)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: isDisabled ? null : _pickCompanyLogo,
          icon: Icon(
            hasLogo ? Icons.swap_horiz_rounded : Icons.upload_rounded,
            size: 18,
          ),
          label: Text(hasLogo ? "Cambiar imagen" : "Subir imagen"),
        ),
        if (hasLogo)
          TextButton.icon(
            onPressed: isDisabled ? null : _removeCompanyLogo,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text("Quitar"),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          ),
      ],
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Logo de la empresa",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Se mostrará en el inicio y en el selector de sucursales. Es solo estético: no se usa en facturas, tickets ni reportes.",
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        actions,
      ],
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 560;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  preview,
                  const SizedBox(height: 14),
                  info,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                preview,
                const SizedBox(width: 18),
                Expanded(child: info),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsCubit = getIt<AppSettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuraciones del Sistema",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Recargar",
            onPressed: () {
              setState(() {
                _initialized = false;
              });
              appSettingsCubit.loadSettings();
            },
          ),
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            bloc: appSettingsCubit,
            builder: (context, state) {
              final isBusy = state is AppSettingsSaving || _isSavingCompanyLogo;
              final currentSettings = appSettingsCubit.currentSettings;
              final hasUnsavedChanges =
                  currentSettings != null && _hasUnsavedChanges(currentSettings);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Badge(
                  alignment: Alignment.topRight,
                  offset: const Offset(-2, 2),
                  smallSize: 8,
                  backgroundColor: Colors.amber,
                  isLabelVisible: hasUnsavedChanges && !isBusy,
                  child: TertiaryMenuButton(
                    foregroundColor: Colors.white,
                    tooltip: "Guardar configuraciones",
                    onPressed:
                        isBusy || state is AppSettingsLoading || state is AppSettingsInitial
                        ? null
                        : _saveSettings,
                    icon: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(isBusy ? "Guardando..." : "Guardar"),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
        bloc: appSettingsCubit,
        listener: (context, state) {
          if (state is AppSettingsLoaded) {
            _syncWithSettings(state.settings);
          } else if (state is AppSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AppSettingsLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppSettingsError && !_initialized) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _initialized = false);
                        getIt<AppSettingsCubit>().loadSettings();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Reintentar"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AppSettingsLoaded) {
            _syncWithSettings(state.settings);
          }

          final isSaving = state is AppSettingsSaving || _isSavingCompanyLogo;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildSectionHeader(
                    icon: Icons.business_rounded,
                    title: "Identidad de la empresa",
                    subtitle: "Imagen corporativa para el inicio y el selector de sucursales",
                  ),
                  const SizedBox(height: 8),
                  _buildCompanyLogoCard(isSaving: isSaving),
                  const SizedBox(height: 24),
                  _buildCurrencySummaryTile(isSaving: isSaving),
                  const SizedBox(height: 12),
                  _buildInvoiceSecondaryTotalSwitch(isSaving: isSaving),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    icon: Icons.trending_up_rounded,
                    title: "Margen de Ganancia Comercial",
                    subtitle: "Parámetros para cálculo sugerido de precios de venta",
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Usar porcentaje de margen por defecto",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Calcula automáticamente el precio de venta a partir del costo promedio al catalogar productos",
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            value: _useDefaultProfitMargin,
                            onChanged: isSaving
                                ? null
                                : (val) {
                                    setState(() {
                                      _useDefaultProfitMargin = val;
                                    });
                                  },
                          ),
                          if (_useDefaultProfitMargin) ...[
                            const Divider(height: 24),
                            TextFormField(
                              controller: _profitMarginController,
                              enabled: !isSaving,
                              onChanged: (_) => _onFieldChanged(),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [const DecimalTextInputFormatter()],
                              decoration: InputDecoration(
                                labelText: "Porcentaje de margen por defecto (%)",
                                hintText: "Ej. 20.0",
                                prefixIcon: const Icon(Icons.percent_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                helperText: "Margen aplicado para calcular el precio de venta sugerido",
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    icon: Icons.dashboard_customize_rounded,
                    title: "Módulos y Operaciones",
                    subtitle: "Habilita o deshabilita funciones en el sistema",
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            "Control de fechas de vencimiento",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Habilita el seguimiento de lotes y alertas de caducidad en inventario",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useExpirationDates,
                          onChanged: isSaving ? null : (val) => setState(() => _useExpirationDates = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Módulo de órdenes / pedidos",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite crear, autorizar y facturar órdenes en el área comercial",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useOrders,
                          onChanged: isSaving ? null : (val) => setState(() => _useOrders = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Módulo de cotizaciones y proformas",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite generar presupuestos y proformas sin afectar inventario ni generar cuentas por cobrar",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useQuotations,
                          onChanged: isSaving ? null : (val) => setState(() => _useQuotations = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.flash_on_rounded, color: Colors.amber),
                          title: const Text(
                            "Búsqueda rápida de productos",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Abre el buscador con botones de agregar y quitar cantidad al agregar productos en móvil (facturas, órdenes y cotizaciones)",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useQuickProductSearch,
                          onChanged: isSaving ? null : (val) => setState(() => _useQuickProductSearch = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Ventas en espera (Hold Sales)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite pausar carritos en terminal de venta para atender a otros clientes",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useHoldSales,
                          onChanged: isSaving ? null : (val) => setState(() => _useHoldSales = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Activar Control de Caja y Turnos",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Requiere abrir turno de caja por cajero para facturar, cobrar y registrar movimientos de efectivo",
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useShifts,
                          onChanged: isSaving ? null : (val) => setState(() => _useShifts = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    icon: Icons.shield_outlined,
                    title: "Reglas de Inventario y Crédito",
                    subtitle: "Restricciones de stock y plazos para clientes",
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Permitir facturación con stock negativo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Permite generar facturas de venta aun si no hay existencias registradas en la sucursal",
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            value: _allowNegativeStock,
                            onChanged: isSaving ? null : (val) => setState(() => _allowNegativeStock = val),
                          ),
                          const Divider(height: 16),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Alertas de stock mínimo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "Resalta en amarillo o rojo los productos que alcancen el límite mínimo",
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            value: _alertMinStock,
                            onChanged: isSaving ? null : (val) => setState(() => _alertMinStock = val),
                          ),
                          const Divider(height: 24),
                          TextFormField(
                            controller: _paymentTermController,
                            enabled: !isSaving,
                            onChanged: (_) => _onFieldChanged(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [IntegerTextInputFormatter()],
                            decoration: InputDecoration(
                              labelText: "Plazo de crédito predeterminado (días)",
                              hintText: "Ej. 30",
                              prefixIcon: const Icon(Icons.calendar_month_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              helperText: "Días de gracia asignados automáticamente a facturas de crédito",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Builder(
                    builder: (context) {
                      final authUser = getIt<AuthCubit>().user;
                      final bool isRootOrAdmin =
                          authUser != null &&
                          (authUser.id == 'root' ||
                              authUser.username.toLowerCase() == 'root' ||
                              authUser.role == 'Admin');

                      if (!isRootOrAdmin) {
                        return const SizedBox.shrink();
                      }
                      if (!context.isDesktop()) {
                        return const SizedBox.shrink();
                      }

                      final currentBranch = getIt<AuthCubit>().currentBranch;
                      final branchName = currentBranch?.name ?? "Sin sucursal seleccionada";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildSectionHeader(
                            icon: Icons.shield_outlined,
                            title: "Zona de Peligro (Solo Desktop / Root)",
                            subtitle: "Acciones irreversibles que impactan el inventario y auditoría",
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                                width: 1.2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.restart_alt_rounded,
                                  color: Colors.red.shade800,
                                  size: 26,
                                ),
                              ),
                              title: const Text(
                                "Reiniciar Inventario a 0",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Genera un ajuste de salida automático que vacía las existencias físicas de la sucursal ($branchName). Irreversible.",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.red.shade900.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                              trailing: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () async {
                                  BranchInDb? target = currentBranch;
                                  if (target == null) {
                                    final allBranches = context.read<BranchesRepository>().branches;
                                    if (allBranches.isNotEmpty) {
                                      final selected = await showBranchSelectionDialog(
                                        context,
                                        allBranches,
                                        currentBranchId: getIt<AuthCubit>().currentBranchId,
                                      );
                                      if (selected == null) return;
                                      target = selected;
                                    }
                                  }

                                  if (target == null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("No hay sucursales disponibles."),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  if (!context.mounted) return;
                                  final result = await showResetInventoryDangerDialog(
                                    context,
                                    branch: target,
                                  );
                                  if (result != null && context.mounted) {
                                    showDialog<void>(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        icon: const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.teal,
                                          size: 44,
                                        ),
                                        title: const Text(
                                          "Inventario Reiniciado",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.message,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 12),
                                            if (result.docNumber.isNotEmpty)
                                              Text(
                                                "• Comprobante: ${result.docNumber}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            Text(
                                              "• Productos ajustados: ${result.adjustedProductsCount}",
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                              "• Unidades descargadas: ${result.totalQuantityRemoved}",
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          FilledButton(
                                            onPressed: () => Navigator.of(dCtx).pop(),
                                            child: const Text("Entendido"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Reiniciar a 0",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({required this.currency});

  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        "${currency.symbol}  ${currency.displayName}",
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
