import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/src/tools/printers/shift_printer.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adaptive_viewer.dart';
import 'package:kardex_app_front/widgets/pdf/shift_close_pdf_template.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

/// Muestra el visor adaptativo de corte de turno con acciones de PDF (A4),
/// Compartir e Imprimir, siguiendo el mismo formato que `InvoiceViewer` y
/// `ReceiptViewer`.
Future<void> showShiftViewerDialog(BuildContext context, ShiftInDb shift) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await showAdaptiveViewer(
    context: context,
    builder: (_) => ShiftViewer(
      shift: shift,
      branch: currentBranch,
      paperSize: paperSize,
    ),
  );
}

/// Visor de corte de turno con acciones de PDF (A4), Compartir e Imprimir.
class ShiftViewer extends StatefulWidget {
  const ShiftViewer({
    super.key,
    required this.shift,
    required this.branch,
    this.paperSize = PaperSize.mm80,
  });

  final ShiftInDb shift;
  final BranchInDb branch;
  final PaperSize paperSize;

  @override
  State<ShiftViewer> createState() => _ShiftViewerState();
}

class _ShiftViewerState extends State<ShiftViewer> {
  ShiftArqueoResponse? _arqueo;

  @override
  void initState() {
    super.initState();
    _loadArqueoDetail();
  }

  Future<void> _loadArqueoDetail() async {
    CompositeRepository? repo;
    try {
      repo = context.read<CompositeRepository>();
    } catch (_) {
      return;
    }

    try {
      final response = await repo.getShiftArqueo(
        shiftId: widget.shift.id,
        includeDocuments: true,
        documentsLimit: 500,
      );
      if (mounted) {
        setState(() {
          _arqueo = response;
        });
      }
    } catch (_) {
      // Si falla la carga extendida, se mantiene el visor funcional con ShiftInDb.
    }
  }

  ShiftInDb get _effectiveShift {
    final arqueo = _arqueo;
    if (arqueo == null) return widget.shift;
    final s = widget.shift;
    final t = arqueo.totals;
    return ShiftInDb(
      id: s.id,
      branchId: s.branchId,
      branchName: s.branchName,
      docNumber: s.docNumber,
      status: s.status,
      initialCash: s.initialCash,
      openingNotes: s.openingNotes,
      openedBy: s.openedBy,
      openedAt: s.openedAt,
      closedBy: s.closedBy,
      closedAt: s.closedAt,
      closingNotes: s.closingNotes,
      countedCash: s.countedCash,
      cashDifference: s.cashDifference,
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
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );
  }

  Future<void> _exportPdf() async {
    final shift = _effectiveShift;
    final template = ShiftClosePdfTemplate(
      shift: shift,
      branch: widget.branch,
      movements: _arqueo?.cashMovements ?? const <ShiftCashMovementInDb>[],
      invoices: _arqueo?.invoices ?? const <ShiftArqueoDocument>[],
      receipts: _arqueo?.receipts ?? const <ShiftArqueoDocument>[],
    );
    await PdfExportTool.export(template, fileName: 'turno_${shift.docNumber}.pdf');
  }

  Future<void> _share() async {
    await shareShiftTicket(
      _effectiveShift,
      widget.branch,
      paperSize: widget.paperSize,
    );
  }

  Future<void> _print() async {
    await printShiftTicket(
      _effectiveShift,
      widget.branch,
      paperSize: widget.paperSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = _effectiveShift;
    return Scaffold(
      appBar: AppBar(
        title: Text('Turno #${shift.docNumber}'),
        actions: [
          IconButton(
            tooltip: 'Exportar PDF (A4)',
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: 'Compartir Turno',
            onPressed: _share,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: 'Imprimir Turno',
            onPressed: _print,
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ShiftViewerContent(
                shift: shift,
                branch: widget.branch,
                arqueo: _arqueo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenido visual tipo comprobante de [showShiftViewerDialog].
class ShiftViewerContent extends StatelessWidget {
  const ShiftViewerContent({
    super.key,
    required this.shift,
    required this.branch,
    this.arqueo,
  });

  final ShiftInDb shift;
  final BranchInDb branch;
  final ShiftArqueoResponse? arqueo;

  @override
  Widget build(BuildContext context) {
    final displayDate = DateTime.fromMillisecondsSinceEpoch(
      shift.closedAt ?? shift.openedAt,
    );
    final dateFmt = DateFormat('dd/MM/yyyy hh:mm a');
    final openedAtStr = dateFmt.format(
      DateTime.fromMillisecondsSinceEpoch(shift.openedAt),
    );
    final closedAtStr = shift.closedAt != null
        ? dateFmt.format(DateTime.fromMillisecondsSinceEpoch(shift.closedAt!))
        : null;

    final countedDocs = <ShiftArqueoDocument>[
      ...(arqueo?.invoices ?? const <ShiftArqueoDocument>[]),
      ...(arqueo?.receipts ?? const <ShiftArqueoDocument>[]),
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

    final diffColor = shift.cashDifference == 0
        ? AppThemeTokens.success
        : (shift.cashDifference > 0
            ? AppThemeTokens.indigo
            : AppThemeTokens.danger);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Corte de Turno',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No. ${shift.docNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateTimeTool.formatddMMyy(displayDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateTimeTool.formatHHmm(displayDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            branch.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (branch.formattedRuc != null)
            Text(
              branch.formattedRuc!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          if (branch.address.isNotEmpty)
            Text(
              branch.address,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          if (branch.phone.isNotEmpty)
            Text(
              'Tel: ${branch.phone}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          const SizedBox(height: 8),
          _MetaLine(label: 'Estado', value: shift.status.display),
          _MetaLine(label: 'Cajero apertura', value: shift.openedBy.name),
          _MetaLine(label: 'Apertura', value: openedAtStr),
          if (shift.closedBy != null)
            _MetaLine(label: 'Cajero cierre', value: shift.closedBy!.name),
          if (closedAtStr != null)
            _MetaLine(label: 'Cierre', value: closedAtStr),
          const Divider(height: 20, thickness: 1),
          const Text(
            'CAJA FÍSICA (EFECTIVO)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          _AmountRow('Fondo inicial', shift.initialCash, prefix: '+'),
          _AmountRow(
            'Facturas efectivo (${shift.invoiceCount})',
            shift.invoiceCashTotal,
            prefix: '+',
          ),
          _AmountRow(
            'Recibos efectivo (${shift.receiptCount})',
            shift.receiptCashTotal,
            prefix: '+',
          ),
          _AmountRow('Entradas de caja', shift.cashInTotal, prefix: '+'),
          _AmountRow(
            'Devoluciones (${shift.devolutionCount})',
            shift.devolutionTotal,
            prefix: '-',
          ),
          _AmountRow('Salidas / Gastos', shift.cashOutTotal, prefix: '-'),
          const Divider(height: 16),
          _AmountRow('Efectivo esperado', shift.expectedCash, bold: true),
          if (shift.status == ShiftStatus.closed) ...[
            _AmountRow('Efectivo contado', shift.countedCash, bold: true),
            _AmountRow(
              'Diferencia',
              shift.cashDifference,
              bold: true,
              valueColor: diffColor,
            ),
          ],
          const Divider(height: 20, thickness: 1),
          const Text(
            'OTROS MEDIOS Y CONSOLIDADO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          _AmountRow('Transferencias', shift.totalTransfers),
          for (final bank in transferByBank)
            _AmountRow(
              '  • ${bank.bankName} (${bank.count})',
              bank.totalCents,
              subtle: true,
            ),
          _AmountRow('Tarjetas y otros', shift.totalCardsAndOthers),
          for (final bank in cardByBank)
            _AmountRow(
              '  • ${bank.bankName} (${bank.count})',
              bank.totalCents,
              subtle: true,
            ),
          _AmountRow('Ventas a crédito', shift.invoiceCreditTotal),
          _AmountRow(
            'Notas de crédito (${shift.creditNoteCount})',
            shift.creditNoteTotal,
          ),
          const Divider(height: 16),
          _AmountRow(
            'TOTAL GENERAL',
            shift.grandTotal,
            bold: true,
            fontSize: 16,
          ),
          if (shift.openingNotes.isNotEmpty || shift.closingNotes.isNotEmpty) ...[
            const Divider(height: 20, thickness: 1),
            if (shift.openingNotes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Nota de apertura: ${shift.openingNotes}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ),
            if (shift.closingNotes.isNotEmpty)
              Text(
                'Observaciones de cierre: ${shift.closingNotes}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(
    this.label,
    this.amount, {
    this.bold = false,
    this.subtle = false,
    this.prefix = '',
    this.fontSize = 14,
    this.valueColor,
  });

  final String label;
  final int amount;
  final bool bold;
  final bool subtle;
  final String prefix;
  final double fontSize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final color = subtle ? Colors.grey.shade700 : Colors.black87;
    final weight = bold ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: subtle ? 13 : fontSize,
                fontWeight: weight,
                color: color,
              ),
            ),
          ),
          Text(
            '$prefix${NumberFormatter.convertToMoneyLike(amount)}',
            style: TextStyle(
              fontSize: subtle ? 13 : fontSize,
              fontWeight: weight,
              color: valueColor ?? color,
            ),
          ),
        ],
      ),
    );
  }
}
