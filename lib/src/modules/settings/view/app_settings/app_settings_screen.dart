import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

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
  bool _useDefaultProfitMargin = false;
  bool _useExpirationDates = true;
  bool _useOrders = true;
  bool _useQuotations = true;
  bool _allowNegativeStock = false;
  bool _alertMinStock = true;
  bool _useHoldSales = true;

  @override
  void initState() {
    super.initState();
    _profitMarginController = TextEditingController();
    _paymentTermController = TextEditingController();
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
      _initialized = true;
    }
  }

  Future<void> _saveSettings() async {
    final profitMargin = double.tryParse(_profitMarginController.text) ?? 20.0;
    final paymentTerm = int.tryParse(_paymentTermController.text) ?? 30;

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
    );

    final success =
        await context.read<AppSettingsCubit>().updateSettings(update);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones del Sistema"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Recargar",
            onPressed: () {
              setState(() {
                _initialized = false;
              });
              context.read<AppSettingsCubit>().loadSettings();
            },
          ),
        ],
      ),
      body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
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

          if (state is AppSettingsLoaded) {
            _syncWithSettings(state.settings);
          }

          final isSaving = state is AppSettingsSaving;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildSectionHeader(
                    icon: Icons.trending_up_rounded,
                    title: "Margen de Ganancia Comercial",
                    subtitle:
                        "Parámetros para cálculo sugerido de precios de venta",
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
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [DecimalTextInputFormatter()],
                              decoration: InputDecoration(
                                labelText:
                                    "Porcentaje de margen por defecto (%)",
                                hintText: "Ej. 20.0",
                                prefixIcon: const Icon(Icons.percent_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                helperText:
                                    "Margen aplicado para calcular el precio de venta sugerido",
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
                    subtitle:
                        "Habilita o deshabilita funciones en el sistema",
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
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useExpirationDates,
                          onChanged: isSaving
                              ? null
                              : (val) =>
                                  setState(() => _useExpirationDates = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Módulo de órdenes / pedidos",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite crear, autorizar y facturar órdenes en el área comercial",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useOrders,
                          onChanged: isSaving
                              ? null
                              : (val) => setState(() => _useOrders = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Módulo de cotizaciones y proformas",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite generar presupuestos y proformas sin afectar inventario ni generar cuentas por cobrar",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useQuotations,
                          onChanged: isSaving
                              ? null
                              : (val) => setState(() => _useQuotations = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text(
                            "Ventas en espera (Hold Sales)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Permite pausar carritos en terminal de venta para atender a otros clientes",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          value: _useHoldSales,
                          onChanged: isSaving
                              ? null
                              : (val) => setState(() => _useHoldSales = val),
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
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                            value: _allowNegativeStock,
                            onChanged: isSaving
                                ? null
                                : (val) =>
                                    setState(() => _allowNegativeStock = val),
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
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                            value: _alertMinStock,
                            onChanged: isSaving
                                ? null
                                : (val) =>
                                    setState(() => _alertMinStock = val),
                          ),
                          const Divider(height: 24),
                          TextFormField(
                            controller: _paymentTermController,
                            enabled: !isSaving,
                            keyboardType: TextInputType.number,
                            inputFormatters: [IntegerTextInputFormatter()],
                            decoration: InputDecoration(
                              labelText:
                                  "Plazo de crédito predeterminado (días)",
                              hintText: "Ej. 30",
                              prefixIcon:
                                  const Icon(Icons.calendar_month_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              helperText:
                                  "Días de gracia asignados automáticamente a facturas de crédito",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving ? null : _saveSettings,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        isSaving
                            ? "Guardando..."
                            : "Guardar Configuraciones",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
