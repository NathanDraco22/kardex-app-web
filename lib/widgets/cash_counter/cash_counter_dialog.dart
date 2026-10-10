import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/buttons/secondary_menu_button.dart';
import 'package:toastification/toastification.dart';

import 'cash_counter_export_dialog.dart';
import 'cash_counter_models.dart';
import 'cash_counter_storage.dart';

class CashCounterDialog extends StatefulWidget {
  final String? branchId;
  final String? userId;
  final String? userName;
  final DateTime? date;
  final double? expectedCash;
  final bool isDialog;

  const CashCounterDialog({
    super.key,
    this.branchId,
    this.userId,
    this.userName,
    this.date,
    this.expectedCash,
    this.isDialog = true,
  });

  /// Abre el contador de efectivo respetando el patrón responsivo del sistema:
  /// - En Desktop (>= 840 dp): se despliega en un `Dialog` modal centrado.
  /// - En Teléfonos y Tablets (< 840 dp): se navega como sub-vista completa vía `Navigator.push` con `Scaffold` y `AppBar`.
  static Future<CashCountRecord?> show(
    BuildContext context, {
    String? branchId,
    String? userId,
    String? userName,
    DateTime? date,
    double? expectedCash,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (context.isDesktop()) {
      return await showDialog<CashCountRecord?>(
        context: context,
        barrierDismissible: true,
        builder: (context) => CashCounterDialog(
          branchId: branchId,
          userId: userId,
          userName: userName,
          date: date,
          expectedCash: expectedCash,
          isDialog: true,
        ),
      );
    } else {
      return await Navigator.push<CashCountRecord?>(
        context,
        MaterialPageRoute(
          builder: (context) => CashCounterDialog(
            branchId: branchId,
            userId: userId,
            userName: userName,
            date: date,
            expectedCash: expectedCash,
            isDialog: false,
          ),
        ),
      );
    }
  }

  @override
  State<CashCounterDialog> createState() => _CashCounterDialogState();
}

class _CashCounterDialogState extends State<CashCounterDialog> {
  final CashCounterStorage _storage = CashCounterStorage();
  late CashCountRecord _record;

  bool _isLoading = true;
  bool _isSaving = false;
  int _currentTab = 0; // 0: Córdobas, 1: Dólares, 2: Resumen

  final Map<double, TextEditingController> _cordobaControllers = {};
  final Map<double, TextEditingController> _dollarControllers = {};
  late TextEditingController _exchangeRateController;

  Timer? _debounceSaveTimer;

  final NumberFormat _moneyFmt = NumberFormat('#,##0.00', 'en_US');
  final NumberFormat _rateFmt = NumberFormat('#,##0.##', 'en_US');

  @override
  void initState() {
    super.initState();
    _exchangeRateController = TextEditingController();

    for (final den in CashDenominations.cordobas) {
      _cordobaControllers[den.value] = TextEditingController(text: '0');
    }
    for (final den in CashDenominations.dollars) {
      _dollarControllers[den.value] = TextEditingController(text: '0');
    }

    _loadExistingRecord();
  }

  @override
  void dispose() {
    _debounceSaveTimer?.cancel();
    _exchangeRateController.dispose();
    for (final c in _cordobaControllers.values) {
      c.dispose();
    }
    for (final c in _dollarControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingRecord() async {
    final existing = await _storage.getCount();
    final lastRate = await _storage.getLastExchangeRate();

    if (!mounted) return;

    final effectiveDate = widget.date ?? DateTime.now();
    final effectiveBranchId = widget.branchId ?? '';
    final effectiveUserId = widget.userId ?? '';

    if (existing != null) {
      _record = existing.copyWith(
        branchId: effectiveBranchId.isNotEmpty ? effectiveBranchId : existing.branchId,
        userId: effectiveUserId.isNotEmpty ? effectiveUserId : existing.userId,
        date: effectiveDate,
      );
    } else {
      _record = CashCountRecord(
        branchId: effectiveBranchId,
        userId: effectiveUserId,
        date: effectiveDate,
        exchangeRate: lastRate,
      );
    }

    _exchangeRateController.text = _record.exchangeRate.toString();

    for (final den in CashDenominations.cordobas) {
      final qty = _record.getCordobaCount(den.value);
      _cordobaControllers[den.value]?.text = qty > 0 ? qty.toString() : '';
    }

    for (final den in CashDenominations.dollars) {
      final qty = _record.getDollarCount(den.value);
      _dollarControllers[den.value]?.text = qty > 0 ? qty.toString() : '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _triggerAutoSave() {
    _debounceSaveTimer?.cancel();
    setState(() {
      _isSaving = true;
    });

    _debounceSaveTimer = Timer(const Duration(milliseconds: 350), () async {
      await _storage.saveCount(_record);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    });
  }

  void _onCordobaCountChanged(double value, String text) {
    final qty = int.tryParse(text.trim()) ?? 0;
    final newCounts = Map<double, int>.from(_record.cordobaCounts);
    if (qty > 0) {
      newCounts[value] = qty;
    } else {
      newCounts.remove(value);
    }

    _record = _record.copyWith(cordobaCounts: newCounts);
    _triggerAutoSave();
  }

  void _onDollarCountChanged(double value, String text) {
    final qty = int.tryParse(text.trim()) ?? 0;
    final newCounts = Map<double, int>.from(_record.dollarCounts);
    if (qty > 0) {
      newCounts[value] = qty;
    } else {
      newCounts.remove(value);
    }

    _record = _record.copyWith(dollarCounts: newCounts);
    _triggerAutoSave();
  }

  void _onExchangeRateChanged(String text) {
    final rate = double.tryParse(text.trim());
    if (rate != null && rate > 0) {
      _record = _record.copyWith(exchangeRate: rate);
      _triggerAutoSave();
    }
  }

  void _incrementCordoba(double value) {
    final current = _record.getCordobaCount(value);
    final next = current + 1;
    _cordobaControllers[value]?.text = next.toString();
    _onCordobaCountChanged(value, next.toString());
  }

  void _decrementCordoba(double value) {
    final current = _record.getCordobaCount(value);
    if (current <= 0) return;
    final next = current - 1;
    _cordobaControllers[value]?.text = next > 0 ? next.toString() : '';
    _onCordobaCountChanged(value, next.toString());
  }

  void _incrementDollar(double value) {
    final current = _record.getDollarCount(value);
    final next = current + 1;
    _dollarControllers[value]?.text = next.toString();
    _onDollarCountChanged(value, next.toString());
  }

  void _decrementDollar(double value) {
    final current = _record.getDollarCount(value);
    if (current <= 0) return;
    final next = current - 1;
    _dollarControllers[value]?.text = next > 0 ? next.toString() : '';
    _onDollarCountChanged(value, next.toString());
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reiniciar Conteo'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas poner todas las cantidades en 0? '
          'Esta acción borrará el conteo físico actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, Limpiar a 0'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearCount();

      for (final c in _cordobaControllers.values) {
        c.clear();
      }
      for (final c in _dollarControllers.values) {
        c.clear();
      }

      setState(() {
        _record = CashCountRecord(
          branchId: widget.branchId ?? '',
          userId: widget.userId ?? '',
          date: widget.date ?? DateTime.now(),
          exchangeRate: _record.exchangeRate,
        );
      });

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          title: const Text('Conteo reiniciado'),
          description: const Text('Se ha borrado el conteo físico guardado localmente.'),
          autoCloseDuration: const Duration(seconds: 2),
          style: ToastificationStyle.flatColored,
        );
      }
    }
  }

  void _copySummaryToClipboard() {
    final summaryText = _record.generateTextSummary(
      userName: widget.userName,
      expectedCash: widget.expectedCash,
    );

    Clipboard.setData(ClipboardData(text: summaryText)).then((_) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Resumen copiado'),
          description: const Text('El desglose completo se copió al portapapeles.'),
          autoCloseDuration: const Duration(seconds: 3),
          style: ToastificationStyle.flatColored,
        );
      }
    });
  }

  void _openExportOptions() {
    final authState = getIt<AuthCubit>().state;
    if (authState is Authenticated) {
      CashCounterExportDialog.show(
        context,
        record: _record,
        branch: authState.branch,
        userName: widget.userName,
        expectedCash: widget.expectedCash,
      );
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        title: const Text('Sucursal no disponible'),
        description: const Text('No se pudo obtener la información de la sucursal activa para el reporte.'),
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.flatColored,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(widget.date ?? DateTime.now());

    if (_isLoading) {
      return widget.isDialog
          ? const Dialog(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          : Scaffold(
              appBar: AppBar(title: const Text('Contador de Efectivo')),
              body: const Center(child: CircularProgressIndicator()),
            );
    }

    final content = Column(
      children: [
        if (widget.isDialog) ...[
          _buildDesktopHeader(dateStr),
          const Divider(height: 1),
        ],
        _buildTabs(),
        Expanded(
          child: IndexedStack(
            index: _currentTab,
            children: [
              _buildCordobasTab(),
              _buildDollarsTab(),
              _buildSummaryTab(),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildFooter(isDialog: widget.isDialog),
      ],
    );

    if (widget.isDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 780,
            maxHeight: MediaQuery.sizeOf(context).height * 0.90,
          ),
          child: content,
        ),
      );
    }

    // Sub-vista en Pantalla Completa para Teléfonos y Tablets
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contador de Efectivo', style: TextStyle(fontSize: 16.5)),
            Text(
              '${widget.userName ?? "Usuario"} • $dateStr',
              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: _buildSaveBadge(isDarkBackground: true),
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildSaveBadge({bool isDarkBackground = false}) {
    final bgColor = _isSaving
        ? (isDarkBackground ? Colors.amber.shade900.withAlpha(120) : Colors.amber.shade50)
        : (isDarkBackground ? Colors.green.shade900.withAlpha(120) : Colors.green.shade50);

    final borderColor = _isSaving
        ? (isDarkBackground ? Colors.amber.shade300 : Colors.amber.shade200)
        : (isDarkBackground ? Colors.green.shade300 : Colors.green.shade200);

    final textColor = _isSaving
        ? (isDarkBackground ? Colors.amber.shade200 : Colors.amber.shade900)
        : (isDarkBackground ? Colors.green.shade200 : Colors.green.shade900);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isSaving ? Icons.sync_rounded : Icons.save_rounded,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _isSaving ? 'Guardando...' : 'Guardado local',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(String dateStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.point_of_sale_rounded, color: Colors.teal.shade800, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Contador de Efectivo y Billetes',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.userName ?? "Usuario"} • $dateStr',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildSaveBadge(isDarkBackground: false),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(_record),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade50,
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment<int>(
            value: 0,
            label: Text(
              'Córdobas (C\$ ${_moneyFmt.format(_record.totalCordobas)})',
              style: const TextStyle(fontSize: 12),
            ),
            icon: const Icon(Icons.money_rounded, size: 16),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text(
              'Dólares (\$ ${_moneyFmt.format(_record.totalDollars)})',
              style: const TextStyle(fontSize: 12),
            ),
            icon: const Icon(Icons.attach_money_rounded, size: 16),
          ),
          const ButtonSegment<int>(
            value: 2,
            label: Text('Resumen & Arqueo', style: TextStyle(fontSize: 12)),
            icon: Icon(Icons.analytics_outlined, size: 16),
          ),
        ],
        selected: {_currentTab},
        onSelectionChanged: (newSelection) {
          setState(() {
            _currentTab = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildCordobasTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildSectionHeader('Billetes en Córdobas', Icons.payments_rounded, Colors.teal),
        ...CashDenominations.cordobas
            .where((d) => !d.isCoin)
            .map((den) => _buildDenominationRow(
                  den: den,
                  controller: _cordobaControllers[den.value]!,
                  count: _record.getCordobaCount(den.value),
                  onChanged: (text) => _onCordobaCountChanged(den.value, text),
                  onIncrement: () => _incrementCordoba(den.value),
                  onDecrement: () => _decrementCordoba(den.value),
                )),
        const SizedBox(height: 12),
        _buildSectionHeader('Monedas en Córdobas', Icons.monetization_on_rounded, Colors.amber.shade800),
        ...CashDenominations.cordobas
            .where((d) => d.isCoin)
            .map((den) => _buildDenominationRow(
                  den: den,
                  controller: _cordobaControllers[den.value]!,
                  count: _record.getCordobaCount(den.value),
                  onChanged: (text) => _onCordobaCountChanged(den.value, text),
                  onIncrement: () => _incrementCordoba(den.value),
                  onDecrement: () => _decrementCordoba(den.value),
                )),
      ],
    );
  }

  Widget _buildDollarsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Card(
          elevation: 0,
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.currency_exchange_rounded, color: Colors.green.shade800, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tasa de Cambio (1 USD = C\$):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                ),
                SizedBox(
                  width: 95,
                  child: TextField(
                    controller: _exchangeRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.green.shade300),
                      ),
                    ),
                    onChanged: _onExchangeRateChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionHeader('Billetes en Dólares', Icons.attach_money_rounded, Colors.green.shade700),
        ...CashDenominations.dollars.map((den) => _buildDenominationRow(
              den: den,
              controller: _dollarControllers[den.value]!,
              count: _record.getDollarCount(den.value),
              onChanged: (text) => _onDollarCountChanged(den.value, text),
              onIncrement: () => _incrementDollar(den.value),
              onDecrement: () => _decrementDollar(den.value),
            )),
      ],
    );
  }

  Widget _buildSummaryTab() {
    final expected = widget.expectedCash;
    final diff = expected != null ? (_record.grandTotalCordobas - expected) : null;

    Color diffColor = Colors.grey.shade800;
    String diffLabel = 'Sin referencia de sistema';
    IconData diffIcon = Icons.info_outline;

    if (diff != null) {
      if (diff.abs() < 0.01) {
        diffColor = Colors.green.shade700;
        diffLabel = 'Cuadrado Exacto (Diferencia C\$ 0.00)';
        diffIcon = Icons.check_circle_rounded;
      } else if (diff > 0) {
        diffColor = Colors.blue.shade700;
        diffLabel = 'Sobrante de C\$ ${_moneyFmt.format(diff)}';
        diffIcon = Icons.arrow_upward_rounded;
      } else {
        diffColor = Colors.red.shade700;
        diffLabel = 'Faltante de C\$ ${_moneyFmt.format(diff.abs())}';
        diffIcon = Icons.arrow_downward_rounded;
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (expected != null)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: diffColor.withAlpha(80), width: 1.5),
            ),
            color: diffColor.withAlpha(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(diffIcon, color: diffColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Comparativa contra Sistema',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: diffColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Efectivo Esperado en Sistema:', style: TextStyle(fontSize: 13.5)),
                      Text(
                        'C\$ ${_moneyFmt.format(expected)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Efectivo Físico Contado:', style: TextStyle(fontSize: 13.5)),
                      Text(
                        'C\$ ${_moneyFmt.format(_record.grandTotalCordobas)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resultado del Arqueo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        diffLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: diffColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Consolidado de Efectivo Físico',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _buildSummaryLine(
                  'Total Córdobas (C\$):',
                  'C\$ ${_moneyFmt.format(_record.totalCordobas)}',
                  subtitle: '${_record.totalCordobaPieces} piezas físicas',
                ),
                const SizedBox(height: 8),
                _buildSummaryLine(
                  'Total Dólares (\$):',
                  '\$ ${_moneyFmt.format(_record.totalDollars)}',
                  subtitle: '${_record.totalDollarPieces} billetes físicos',
                ),
                const SizedBox(height: 8),
                _buildSummaryLine(
                  'Equivalente USD en Córdobas:',
                  'C\$ ${_moneyFmt.format(_record.totalDollarsInCordobas)}',
                  subtitle: 'Tasa: ${_rateFmt.format(_record.exchangeRate)} C\$/USD',
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GRAN TOTAL FÍSICO:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'C\$ ${_moneyFmt.format(_record.grandTotalCordobas)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13.5)),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildDenominationRow({
    required DenominationConfig den,
    required TextEditingController controller,
    required int count,
    required ValueChanged<String> onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final subtotal = den.value * count;
    final hasPieces = count > 0;
    final isCordoba = den.currency == CashCurrency.cordoba;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasPieces ? (isCordoba ? Colors.teal.shade50.withAlpha(70) : Colors.green.shade50.withAlpha(70)) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasPieces ? (isCordoba ? Colors.teal.shade200 : Colors.green.shade200) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCordoba ? Colors.teal.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              den.isCoin ? Icons.monetization_on_rounded : Icons.payments_rounded,
              size: 20,
              color: isCordoba ? Colors.teal.shade800 : Colors.green.shade800,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 95,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  den.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  den.typeLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 22,
                  color: count > 0 ? Colors.red.shade700 : Colors.grey.shade400,
                ),
                onPressed: count > 0 ? onDecrement : null,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 58,
                height: 36,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: onIncrement,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCordoba ? 'C\$ ${_moneyFmt.format(subtotal)}' : '\$ ${_moneyFmt.format(subtotal)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: hasPieces ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
              if (count > 0)
                Text(
                  '$count ${count == 1 ? "pieza" : "piezas"}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({required bool isDialog}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: isDialog ? const BorderRadius.vertical(bottom: Radius.circular(16)) : null,
      ),
      child: Row(
        children: [
          SecondaryMenuButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Limpiar'),
            onPressed: _confirmClear,
          ),
          const SizedBox(width: 8),
          SecondaryMenuButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar'),
            tooltip: 'Copiar desglose al portapapeles',
            onPressed: _copySummaryToClipboard,
          ),
          const SizedBox(width: 8),
          SecondaryMenuButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Exportar'),
            tooltip: 'Exportar a PDF (Hoja Completa o Ticket)',
            onPressed: _openExportOptions,
          ),
          const Spacer(),
          if (isDialog) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Físico',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  'C\$ ${_moneyFmt.format(_record.grandTotalCordobas)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
          ],
          PrimaryMenuButton(
            label: const Text('Listo'),
            onPressed: () => Navigator.of(context).pop(_record),
          ),
        ],
      ),
    );
  }
}

/// Función auxiliar para abrir el contador de efectivo respetando el estándar del sistema.
Future<CashCountRecord?> showCashCounterDialog(
  BuildContext context, {
  String? branchId,
  String? userId,
  String? userName,
  DateTime? date,
  double? expectedCash,
}) {
  return CashCounterDialog.show(
    context,
    branchId: branchId,
    userId: userId,
    userName: userName,
    date: date,
    expectedCash: expectedCash,
  );
}
