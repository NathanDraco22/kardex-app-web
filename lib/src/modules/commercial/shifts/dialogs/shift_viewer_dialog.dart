import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/write_shift_cash_movements_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/close_shift_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/create_cash_movement_dialog.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_app_front/src/tools/printers/shift_printer.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/pdf/shift_close_pdf_template.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

enum _DocTabFilter { invoices, receipts, devolutions, creditNotes }

class ShiftViewerDialog extends StatefulWidget {
  final ShiftInDb shift;

  const ShiftViewerDialog({super.key, required this.shift});

  static Future<void> show(
    BuildContext context, {
    required ShiftInDb shift,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider(
        create: (_) => WriteShiftCashMovementsCubit(
          repository: ctx.read<ShiftCashMovementsRepository>(),
        ),
        child: ShiftViewerDialog(shift: shift),
      ),
    );
  }

  @override
  State<ShiftViewerDialog> createState() => _ShiftViewerDialogState();
}

class _ShiftViewerDialogState extends State<ShiftViewerDialog> {
  late ShiftInDb _shift;
  ShiftArqueoResponse? _arqueo;
  bool _loading = true;
  String? _loadError;
  _DocTabFilter _docFilter = _DocTabFilter.invoices;

  @override
  void initState() {
    super.initState();
    _shift = widget.shift;
    _loadArqueo();
  }

  Future<void> _loadArqueo() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final response = await context.read<CompositeRepository>().getShiftArqueo(
            shiftId: _shift.id,
            includeDocuments: true,
            documentsLimit: 500,
          );
      if (mounted) {
        setState(() {
          _arqueo = response;
          _shift = response.shift;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  ShiftInDb get _effectiveShift {
    final arqueo = _arqueo;
    if (arqueo == null) return _shift;
    final t = arqueo.totals;
    return ShiftInDb(
      id: _shift.id,
      branchId: _shift.branchId,
      branchName: _shift.branchName,
      docNumber: _shift.docNumber,
      status: _shift.status,
      initialCash: _shift.initialCash,
      openingNotes: _shift.openingNotes,
      openedBy: _shift.openedBy,
      openedAt: _shift.openedAt,
      closedBy: _shift.closedBy,
      closedAt: _shift.closedAt,
      closingNotes: _shift.closingNotes,
      countedCash: _shift.countedCash,
      cashDifference: _shift.cashDifference,
      invoiceCashTotal: t.invoiceCashTotal,
      invoiceCashSalesTotal: t.invoiceCashSalesTotal,
      invoiceCreditTotal: t.invoiceCreditTotal,
      invoiceTotal: t.invoiceTotal,
      invoiceCount: t.invoiceCount,
      receiptCashTotal: t.receiptCashTotal,
      receiptTotal: t.receiptTotal,
      receiptCount: t.receiptCount,
      devolutionTotal: t.devolutionTotal,
      devolutionCount: t.devolutionCount,
      creditNoteTotal: t.creditNoteTotal,
      creditNoteCount: t.creditNoteCount,
      cashInTotal: t.cashInTotal,
      cashOutTotal: t.cashOutTotal,
      expectedCash: t.expectedCash,
      totalTransfers: t.totalTransfers,
      totalCardsAndOthers: t.totalCardsAndOthers,
      grandTotal: t.grandTotal,
      createdAt: _shift.createdAt,
      updatedAt: _shift.updatedAt,
    );
  }

  Future<void> _printTicket() async {
    final branch = getIt<AuthCubit>().currentBranch;
    if (branch == null) return;
    await printShiftTicket(_effectiveShift, branch);
  }

  Future<void> _exportPdf() async {
    final branch = getIt<AuthCubit>().currentBranch;
    if (branch == null) return;
    final movements =
        _arqueo?.cashMovements ?? const <ShiftCashMovementInDb>[];

    final template = ShiftClosePdfTemplate(
      shift: _effectiveShift,
      branch: branch,
      movements: movements,
      invoices: _arqueo?.invoices ?? const <ShiftArqueoDocument>[],
      receipts: _arqueo?.receipts ?? const <ShiftArqueoDocument>[],
    );
    final doc = await template.buildDocument();
    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: 'turno_${_shift.docNumber}.pdf',
    );
  }

  Future<void> _deleteMovement(ShiftCashMovementInDb movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text(
          '¿Deseas eliminar el movimiento #${movement.docNumber} '
          '(${NumberFormatter.convertToMoneyLike(movement.amount)})?'
          '${movement.expenseId != null ? "\n\nTambién se eliminará el gasto operativo vinculado." : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppThemeTokens.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deleted = await context
        .read<WriteShiftCashMovementsCubit>()
        .deleteMovement(movement.id);
    if (!mounted) return;
    if (deleted != null) {
      toastification.show(
        context: context,
        title: const Text('Movimiento eliminado'),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 3),
      );
      _loadArqueo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _shift.status == ShiftStatus.open;
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final docsCount = _arqueo?.totalDocumentsCount ?? 0;

    return DefaultTabController(
      length: 3,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isOpen ? AppThemeTokens.success : AppThemeTokens.indigo)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.point_of_sale_rounded,
                color: isOpen ? AppThemeTokens.success : AppThemeTokens.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Turno #${_shift.docNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isOpen
                                  ? AppThemeTokens.success
                                  : const Color(0xFF64748B))
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _shift.status.display,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOpen
                                ? AppThemeTokens.success
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_shift.openedBy.name} • ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_shift.openedAt))}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isOpen ? 'Actualizar pre-arqueo' : 'Recargar arqueo',
              onPressed: _loading ? null : _loadArqueo,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 660,
          height: 480,
          child: Column(
            children: [
              TabBar(
                labelColor: AppThemeTokens.indigo,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: AppThemeTokens.indigo,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  const Tab(
                    icon: Icon(Icons.summarize_outlined),
                    text: 'Resumen',
                  ),
                  const Tab(
                    icon: Icon(Icons.swap_vert_rounded),
                    text: 'Movimientos',
                  ),
                  Tab(
                    icon: const Icon(Icons.receipt_long_outlined),
                    text: _arqueo != null ? 'Documentos ($docsCount)' : 'Documentos',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSummaryTab(),
                    _buildMovementsTab(isOpen),
                    _buildDocumentsTab(dateFormat),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _printTicket,
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Ticket'),
          ),
          OutlinedButton.icon(
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('PDF'),
          ),
          if (isOpen)
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppThemeTokens.danger),
              onPressed: () async {
                final closed = await CloseShiftDialog.show(context, shift: _shift);
                if (closed != null && mounted) {
                  setState(() {
                    _shift = closed;
                  });
                  _loadArqueo();
                }
              },
              icon: const Icon(Icons.lock_clock_rounded, size: 18),
              label: const Text('Cerrar Turno'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_loading && _arqueo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = _effectiveShift;
    final totals = _arqueo?.totals;
    final countedDocs = <ShiftArqueoDocument>[
      ...(_arqueo?.invoices ?? const <ShiftArqueoDocument>[]),
      ...(_arqueo?.receipts ?? const <ShiftArqueoDocument>[]),
    ].where((d) => d.counted);
    final transferByBank = groupReferencesByBank(
      countedDocs
          .where((d) => d.paymentMethod == 'transfer')
          .map((d) => (bankReference: d.bankReference, amount: d.amount)),
    );
    final cardByBank = groupReferencesByBank(
      countedDocs
          .where((d) => d.paymentMethod == 'card')
          .map((d) => (bankReference: d.bankReference, amount: d.amount)),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loadError != null && _arqueo == null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppThemeTokens.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppThemeTokens.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'Mostrando totales guardados localmente. Error al actualizar: $_loadError',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          _sectionCard(
            title: 'Caja Física (Efectivo)',
            children: [
              _row('Fondo inicial', data.initialCash, prefix: '+'),
              _row(
                'Facturas en efectivo (${data.invoiceCount})',
                data.invoiceCashTotal,
                prefix: '+',
              ),
              _row(
                'Recibos en efectivo (${data.receiptCount})',
                data.receiptCashTotal,
                prefix: '+',
              ),
              _row('Entradas de caja', data.cashInTotal, prefix: '+'),
              _row(
                'Devoluciones (${data.devolutionCount})',
                data.devolutionTotal,
                prefix: '-',
                color: AppThemeTokens.danger,
              ),
              _row(
                'Salidas / Gastos de caja',
                data.cashOutTotal,
                prefix: '-',
                color: AppThemeTokens.danger,
              ),
              const Divider(height: 16),
              _row(
                'Efectivo esperado',
                data.expectedCash,
                bold: true,
                color: AppThemeTokens.indigo,
              ),
              if (_shift.status == ShiftStatus.closed) ...[
                _row('Efectivo contado', _shift.countedCash, bold: true),
                _row(
                  'Diferencia',
                  _shift.cashDifference,
                  bold: true,
                  color: _shift.cashDifference == 0
                      ? AppThemeTokens.success
                      : (_shift.cashDifference > 0
                          ? AppThemeTokens.indigo
                          : AppThemeTokens.danger),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Otros Medios y Consolidado',
            children: [
              _row('Transferencias', data.totalTransfers),
              if (totals != null &&
                  (totals.invoiceTransferTotal > 0 ||
                      totals.receiptTransferTotal > 0)) ...[
                _subRow('Facturas', totals.invoiceTransferTotal),
                _subRow('Recibos', totals.receiptTransferTotal),
              ],
              for (final bank in transferByBank)
                _subRow('${bank.bankName} (${bank.count})', bank.totalCents),
              _row('Tarjetas y otros', data.totalCardsAndOthers),
              if (totals != null &&
                  (totals.invoiceCardTotal > 0 ||
                      totals.invoiceOtherTotal > 0 ||
                      totals.receiptCardTotal > 0 ||
                      totals.receiptOtherTotal > 0)) ...[
                _subRow(
                  'Tarjetas (Facturas / Recibos)',
                  totals.invoiceCardTotal + totals.receiptCardTotal,
                ),
                for (final bank in cardByBank)
                  _subRow('${bank.bankName} (${bank.count})', bank.totalCents),
                _subRow(
                  'Otros (Facturas / Recibos)',
                  totals.invoiceOtherTotal + totals.receiptOtherTotal,
                ),
              ],
              _row('Ventas a crédito', data.invoiceCreditTotal),
              _row('Notas de crédito (${data.creditNoteCount})', data.creditNoteTotal),
              const Divider(height: 16),
              _row(
                'Total General',
                data.grandTotal,
                bold: true,
                color: AppThemeTokens.success,
              ),
            ],
          ),
          if (_shift.openingNotes.isNotEmpty || _shift.closingNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Notas',
              children: [
                if (_shift.openingNotes.isNotEmpty)
                  Text(
                    'Apertura: ${_shift.openingNotes}',
                    style: const TextStyle(fontSize: 13),
                  ),
                if (_shift.closingNotes.isNotEmpty)
                  Text(
                    'Cierre: ${_shift.closingNotes}',
                    style: const TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMovementsTab(bool isOpen) {
    if (_loading && _arqueo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = (_arqueo?.cashMovements ?? const <ShiftCashMovementInDb>[])
        .where((m) => !m.isDeleted)
        .toList();

    return Column(
      children: [
        if (isOpen)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () async {
                final created = await showCreateCashMovementDialog(
                  context,
                  shift: _shift,
                );
                if (created != null && mounted) {
                  _loadArqueo();
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nuevo Movimiento'),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'No hay movimientos manuales registrados en este turno.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final m = list[index];
                    final isIn = m.type == CashMovementType.inMovement;
                    final color = isIn ? AppThemeTokens.success : AppThemeTokens.danger;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isIn
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${m.docNumber} • ${m.reason}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${m.type.display} • ${m.createdBy.name}'
                                  '${m.registerAsExpense ? " • Gasto (${m.expenseCategory ?? 'General'})" : ""}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIn ? '+' : '-'}${NumberFormatter.convertToMoneyLike(m.amount)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          if (isOpen)
                            IconButton(
                              tooltip: 'Eliminar movimiento',
                              onPressed: () => _deleteMovement(m),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppThemeTokens.danger,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(DateFormat dateFormat) {
    if (_loading && _arqueo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final arqueo = _arqueo;
    if (arqueo == null) {
      return Center(
        child: Text(
          _loadError != null
              ? 'No se pudieron cargar los documentos: $_loadError'
              : 'Sin datos de documentos disponibles.',
          style: const TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    final List<ShiftArqueoDocument> docs;
    switch (_docFilter) {
      case _DocTabFilter.invoices:
        docs = arqueo.invoices;
      case _DocTabFilter.receipts:
        docs = arqueo.receipts;
      case _DocTabFilter.devolutions:
        docs = arqueo.devolutions;
      case _DocTabFilter.creditNotes:
        docs = arqueo.creditNotes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (arqueo.meta.truncated == true)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemeTokens.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Mostrando hasta ${arqueo.meta.documentsLimit} documentos por categoría.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _docFilterChip(
                _DocTabFilter.invoices,
                'Facturas (${arqueo.invoices.length})',
              ),
              const SizedBox(width: 6),
              _docFilterChip(
                _DocTabFilter.receipts,
                'Recibos (${arqueo.receipts.length})',
              ),
              const SizedBox(width: 6),
              _docFilterChip(
                _DocTabFilter.devolutions,
                'Devoluciones (${arqueo.devolutions.length})',
              ),
              const SizedBox(width: 6),
              _docFilterChip(
                _DocTabFilter.creditNotes,
                'Notas Crédito (${arqueo.creditNotes.length})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: docs.isEmpty
              ? const Center(
                  child: Text(
                    'No hay documentos en esta categoría para este turno.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final dt = DateTime.fromMillisecondsSinceEpoch(doc.createdAt);
                    final subtitleParts = <String>[
                      if (doc.clientName != null && doc.clientName!.isNotEmpty)
                        doc.clientName!,
                      if (doc.paymentMethod != null && doc.paymentMethod!.isNotEmpty)
                        _formatPaymentMethod(doc.paymentMethod!),
                      if (doc.referenceDocNumber != null &&
                          doc.referenceDocNumber!.isNotEmpty)
                        'Ref: #${doc.referenceDocNumber}',
                      dateFormat.format(dt),
                    ];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '#${doc.docNumber}',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (doc.counted
                                                ? AppThemeTokens.success
                                                : const Color(0xFF94A3B8))
                                            .withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        doc.counted
                                            ? 'Contabilizado'
                                            : (doc.status ?? 'Excluido'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: doc.counted
                                              ? AppThemeTokens.success
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (subtitleParts.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      subtitleParts.join(' • '),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            NumberFormatter.convertToMoneyLike(doc.amount),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _docFilterChip(_DocTabFilter filter, String label) {
    final selected = _docFilter == filter;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _docFilter = filter),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'transfer':
        return 'Transferencia';
      case 'card':
        return 'Tarjeta';
      case 'credit':
        return 'Crédito';
      case 'other':
        return 'Otro';
      default:
        return method;
    }
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String label,
    int amount, {
    String prefix = '',
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              color: const Color(0xFF334155),
            ),
          ),
          Text(
            '$prefix${NumberFormatter.convertToMoneyLike(amount)}',
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 1, bottom: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(amount),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
