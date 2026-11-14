import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/write_shifts_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/write_shifts_state.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:toastification/toastification.dart';

class CloseShiftDialog extends StatefulWidget {
  final ShiftInDb shift;

  const CloseShiftDialog({super.key, required this.shift});

  static Future<ShiftInDb?> show(
    BuildContext context, {
    required ShiftInDb shift,
  }) {
    return showDialog<ShiftInDb?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider(
        create: (_) => WriteShiftsCubit(
          shiftsRepository: ctx.read<ShiftsRepository>(),
        )..loadPreview(shift.id),
        child: CloseShiftDialog(shift: shift),
      ),
    );
  }

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _countedController = TextEditingController();
  final _notesController = TextEditingController();
  ShiftPreview? _preview;

  @override
  void dispose() {
    _countedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _countedCash =>
      NumberFormatter.parseMoneyToCents(_countedController.text);

  Future<void> _openCashCounter() async {
    final user = getIt<AuthCubit>().user;
    final record = await CashCounterDialog.show(
      context,
      branchId: widget.shift.branchId,
      userId: user?.id,
      userName: user?.username,
      date: DateTime.now(),
      expectedCash: (_preview?.expectedCash ?? 0) / 100.0,
    );
    if (record != null && mounted) {
      setState(() {
        _countedController.text = record.grandTotalCordobas.toStringAsFixed(2);
      });
    }
  }

  Future<void> _confirmClose() async {
    if (_countedController.text.trim().isEmpty) {
      toastification.show(
        context: context,
        title: const Text('Ingresa el efectivo contado en caja'),
        type: ToastificationType.warning,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    final user = getIt<AuthCubit>().user;
    if (user == null) return;

    final request = CloseShiftRequest(
      countedCash: _countedCash,
      closingNotes: _notesController.text.trim(),
      closedBy: UserInfo(
        id: user.id,
        name: user.username,
      ),
    );

    final closed = await context.read<WriteShiftsCubit>().closeShift(
          widget.shift.id,
          request,
        );
    if (!mounted) return;
    if (closed != null) {
      toastification.show(
        context: context,
        title: Text('Turno #${closed.docNumber} cerrado'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.of(context).pop(closed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WriteShiftsCubit, WriteShiftsState>(
      listener: (context, state) {
        if (state is ShiftPreviewLoaded) {
          setState(() {
            _preview = state.preview;
          });
        } else if (state is WriteShiftsError) {
          toastification.show(
            context: context,
            title: const Text('Error en arqueo de turno'),
            description: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WriteShiftsLoading;
        final preview = _preview;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: AppThemeTokens.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arqueo y Cierre — Turno #${widget.shift.docNumber}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.shift.branchName,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: preview == null
                ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCashBreakdownCard(preview),
                        const SizedBox(height: 12),
                        _buildOtherMethodsCard(preview),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _countedController,
                                enabled: !isLoading,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: const [
                                  DecimalTextInputFormatter(),
                                ],
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Efectivo físico contado',
                                  prefixIcon: const Icon(Icons.payments_rounded),
                                  prefixText: '${NumberFormatter.currencySymbol} ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : _openCashCounter,
                                icon: const Icon(Icons.dialpad_rounded),
                                label: const Text('Contar Billetes'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDifferenceBanner(preview.expectedCash),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          enabled: !isLoading,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Observaciones de cierre (opcional)',
                            prefixIcon: const Icon(Icons.notes_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Row(
                            children: [
                              Expanded(
                                child: CustomSlider(
                                  hintText: 'Desliza para Cerrar Turno',
                                  hintIcon: Icons.lock_outline_rounded,
                                  sliderColor: AppThemeTokens.danger,
                                  sliderText: 'Cerrar',
                                  onSubmit: _confirmClose,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCashBreakdownCard(ShiftPreview preview) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Caja Física (Efectivo)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _metricRow('Fondo inicial', preview.initialCash, prefix: '+'),
          _metricRow('Facturas en efectivo (${preview.invoiceCount})', preview.invoiceCashTotal, prefix: '+'),
          _metricRow('Recibos en efectivo (${preview.receiptCount})', preview.receiptCashTotal, prefix: '+'),
          _metricRow('Entradas de caja', preview.cashInTotal, prefix: '+'),
          _metricRow('Devoluciones (${preview.devolutionCount})', preview.devolutionTotal, prefix: '-', color: AppThemeTokens.danger),
          _metricRow('Salidas / Gastos de caja', preview.cashOutTotal, prefix: '-', color: AppThemeTokens.danger),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Efectivo Esperado en Gaveta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                NumberFormatter.convertToMoneyLike(preview.expectedCash),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethodsCard(ShiftPreview preview) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otros Medios y Consolidado',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _metricRow('Transferencias', preview.totalTransfers),
          _metricRow('Tarjetas / Cheques / Otros', preview.totalCardsAndOthers),
          _metricRow('Ventas a crédito', preview.invoiceCreditTotal),
          _metricRow('Notas de crédito (${preview.creditNoteCount})', preview.creditNoteTotal),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total General del Turno',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                NumberFormatter.convertToMoneyLike(preview.grandTotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceBanner(int expectedCash) {
    if (_countedController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final diff = _countedCash - expectedCash;
    final Color color;
    final IconData icon;
    final String label;

    if (diff == 0) {
      color = AppThemeTokens.success;
      icon = Icons.check_circle_outline_rounded;
      label = 'Cuadre exacto';
    } else if (diff > 0) {
      color = AppThemeTokens.indigo;
      icon = Icons.trending_up_rounded;
      label = 'Sobrante: +${NumberFormatter.convertToMoneyLike(diff)}';
    } else {
      color = AppThemeTokens.danger;
      icon = Icons.warning_amber_rounded;
      label = 'Faltante: -${NumberFormatter.convertToMoneyLike(diff.abs())}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, int amount, {String prefix = '', Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          Text(
            '$prefix${NumberFormatter.convertToMoneyLike(amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
