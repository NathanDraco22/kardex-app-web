import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ShiftClosePdfTemplate implements PdfTemplate {
  final ShiftInDb shift;
  final BranchInDb branch;
  final List<ShiftCashMovementInDb> movements;
  final List<ShiftArqueoDocument> invoices;
  final List<ShiftArqueoDocument> receipts;

  ShiftClosePdfTemplate({
    required this.shift,
    required this.branch,
    this.movements = const [],
    this.invoices = const [],
    this.receipts = const [],
  });

  @override
  Future<pw.Document> buildDocument() async {
    await branch.resolveLogoBytes();
    final doc = await PdfTheme.newDocument();
    final dateF = DateFormat('dd/MM/yyyy hh:mm a');
    final nowStr = dateF.format(DateTime.now());

    final countedDocs = <ShiftArqueoDocument>[...invoices, ...receipts]
        .where((d) => d.counted);
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

    final activeMovements = movements.where((m) => !m.isDeleted).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 32),
        footer: (context) => _buildFooter(context, nowStr),
        build: (context) => [
          _buildHeader(nowStr),
          pw.SizedBox(height: 12),
          _buildShiftMetaCard(dateF),
          pw.SizedBox(height: 14),
          _buildKpiRow(),
          pw.SizedBox(height: 16),
          _sectionTitle('1. Resumen de Caja Física (Efectivo)'),
          _buildKeyValueTable([
            _SummaryRow(
              'Fondo inicial de caja',
              NumberFormatter.convertToMoneyLike(shift.initialCash),
            ),
            _SummaryRow(
              'Facturas en efectivo (${shift.invoiceCount})',
              '+${NumberFormatter.convertToMoneyLike(shift.invoiceCashTotal)}',
            ),
            _SummaryRow(
              'Recibos / abonos en efectivo (${shift.receiptCount})',
              '+${NumberFormatter.convertToMoneyLike(shift.receiptCashTotal)}',
            ),
            _SummaryRow(
              'Entradas manuales de caja',
              '+${NumberFormatter.convertToMoneyLike(shift.cashInTotal)}',
            ),
            _SummaryRow(
              'Devoluciones en efectivo (${shift.devolutionCount})',
              '-${NumberFormatter.convertToMoneyLike(shift.devolutionTotal)}',
            ),
            _SummaryRow(
              'Salidas / gastos de caja',
              '-${NumberFormatter.convertToMoneyLike(shift.cashOutTotal)}',
            ),
            _SummaryRow(
              'EFECTIVO ESPERADO EN CAJA',
              NumberFormatter.convertToMoneyLike(shift.expectedCash),
              isTotal: true,
            ),
            if (shift.status == ShiftStatus.closed) ...[
              _SummaryRow(
                'Efectivo contado (físico)',
                NumberFormatter.convertToMoneyLike(shift.countedCash),
              ),
              _SummaryRow(
                'DIFERENCIA DE CAJA',
                NumberFormatter.convertToMoneyLike(shift.cashDifference),
                isTotal: true,
              ),
            ],
          ]),
          pw.SizedBox(height: 16),
          _sectionTitle('2. Otros Medios de Pago y Consolidado'),
          _buildKeyValueTable([
            _SummaryRow(
              'Transferencias bancarias',
              NumberFormatter.convertToMoneyLike(shift.totalTransfers),
              isBold: transferByBank.isNotEmpty,
            ),
            for (final bank in transferByBank)
              _SummaryRow(
                '• ${bank.bankName} (${bank.count})',
                NumberFormatter.convertToMoneyLike(bank.totalCents),
                isSubItem: true,
              ),
            _SummaryRow(
              'Tarjetas / Cheques / Otros',
              NumberFormatter.convertToMoneyLike(shift.totalCardsAndOthers),
              isBold: cardByBank.isNotEmpty,
            ),
            for (final bank in cardByBank)
              _SummaryRow(
                '• Tarjeta ${bank.bankName} (${bank.count})',
                NumberFormatter.convertToMoneyLike(bank.totalCents),
                isSubItem: true,
              ),
            _SummaryRow(
              'Ventas al crédito emitidas',
              NumberFormatter.convertToMoneyLike(shift.invoiceCreditTotal),
            ),
            _SummaryRow(
              'Notas de crédito (${shift.creditNoteCount})',
              NumberFormatter.convertToMoneyLike(shift.creditNoteTotal),
            ),
            _SummaryRow(
              'TOTAL GENERAL DE OPERACIONES',
              NumberFormatter.convertToMoneyLike(shift.grandTotal),
              isTotal: true,
            ),
          ]),
          if (activeMovements.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('3. Movimientos Manuales de Caja (${activeMovements.length})'),
            _buildMovementsTable(activeMovements),
          ],
          if (shift.closingNotes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _buildNotesBox(shift.closingNotes.trim()),
          ],
          pw.SizedBox(height: 28),
          _buildSignaturesBlock(),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader(String nowStr) {
    final branchImage = branch.image;

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (branchImage != null && branchImage.isNotEmpty) ...[
                    pw.Image(
                      pw.MemoryImage(branchImage),
                      width: 48,
                      height: 48,
                      fit: pw.BoxFit.contain,
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          branch.name,
                          style: const pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        if (branch.address.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            branch.address,
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                          ),
                        ],
                        if (branch.phone.isNotEmpty || branch.email.isNotEmpty)
                          pw.Text(
                            [
                              if (branch.phone.isNotEmpty) 'Tel: ${branch.phone}',
                              if (branch.email.isNotEmpty) branch.email,
                            ].join('  |  '),
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.black, width: 1.2),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    'ARQUEO DE TURNO #${shift.docNumber}',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Estado: ${shift.status.display.toUpperCase()}',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  'Impreso: $nowStr',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1.5, color: PdfColors.black),
      ],
    );
  }

  pw.Widget _buildShiftMetaCard(DateFormat dateF) {
    final openedAtStr = dateF.format(DateTime.fromMillisecondsSinceEpoch(shift.openedAt));
    final closedAtStr = shift.closedAt != null
        ? dateF.format(DateTime.fromMillisecondsSinceEpoch(shift.closedAt!))
        : 'Turno en curso';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metaLine('Cajero apertura:', shift.openedBy.name),
                pw.SizedBox(height: 3),
                _metaLine('Fecha apertura:', openedAtStr),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metaLine('Cerrado por:', shift.closedBy?.name ?? 'Pendiente'),
                pw.SizedBox(height: 3),
                _metaLine('Fecha cierre:', closedAtStr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _metaLine(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
        ),
        pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildKpiRow() {
    final isClosed = shift.status == ShiftStatus.closed;
    final cards = <pw.Widget>[
      _kpiCard(
        'EFECTIVO ESPERADO',
        NumberFormatter.convertToMoneyLike(shift.expectedCash),
      ),
      if (isClosed) ...[
        _kpiCard(
          'EFECTIVO CONTADO',
          NumberFormatter.convertToMoneyLike(shift.countedCash),
        ),
        _kpiCard(
          'DIFERENCIA',
          NumberFormatter.convertToMoneyLike(shift.cashDifference),
          emphasized: shift.cashDifference != 0,
        ),
      ],
      _kpiCard(
        'TOTAL GENERAL',
        NumberFormatter.convertToMoneyLike(shift.grandTotal),
        emphasized: true,
      ),
    ];

    final spaced = <pw.Widget>[];
    for (var i = 0; i < cards.length; i++) {
      spaced.add(pw.Expanded(child: cards[i]));
      if (i < cards.length - 1) {
        spaced.add(pw.SizedBox(width: 8));
      }
    }

    return pw.Row(children: spaced);
  }

  pw.Widget _kpiCard(String label, String value, {bool emphasized = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: emphasized ? PdfColors.grey100 : PdfColors.white,
        border: pw.Border.all(
          color: emphasized ? PdfColors.black : PdfColors.grey400,
          width: emphasized ? 1.2 : 0.8,
        ),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 4),
      margin: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: const pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildKeyValueTable(List<_SummaryRow> rows) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.3),
      },
      border: pw.TableBorder.symmetric(
        outside: const pw.BorderSide(color: PdfColors.grey400, width: 0.7),
      ),
      children: [
        for (var i = 0; i < rows.length; i++) _buildSummaryTableRow(rows[i], i),
      ],
    );
  }

  pw.TableRow _buildSummaryTableRow(_SummaryRow row, int index) {
    final bgColor = row.isTotal
        ? PdfColors.grey200
        : (index.isEven ? PdfColors.white : PdfColors.grey50);

    final border = row.isTotal
        ? const pw.Border(
            top: pw.BorderSide(color: PdfColors.black, width: 1.0),
            bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.6),
          )
        : const pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          );

    final labelStyle = pw.TextStyle(
      fontSize: row.isSubItem ? 8.5 : 9.5,
      fontWeight: (row.isTotal || row.isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: row.isSubItem ? PdfColors.grey700 : PdfColors.black,
    );

    final valueStyle = pw.TextStyle(
      fontSize: row.isTotal ? 10 : (row.isSubItem ? 8.5 : 9.5),
      fontWeight: (row.isTotal || row.isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: PdfColors.black,
    );

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor, border: border),
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: row.isSubItem ? 20 : 10,
            right: 8,
            top: row.isTotal ? 6 : 4.5,
            bottom: row.isTotal ? 6 : 4.5,
          ),
          child: pw.Text(row.label, style: labelStyle),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: 8,
            right: 10,
            top: row.isTotal ? 6 : 4.5,
            bottom: row.isTotal ? 6 : 4.5,
          ),
          child: pw.Text(
            row.value,
            style: valueStyle,
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildMovementsTable(List<ShiftCashMovementInDb> activeMovements) {
    const headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8.5,
      color: PdfColors.black,
    );

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(1.0),
        1: pw.FlexColumnWidth(1.3),
        2: pw.FlexColumnWidth(3.0),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.4),
      },
      border: pw.TableBorder.symmetric(
        outside: const pw.BorderSide(color: PdfColors.grey400, width: 0.7),
      ),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 1.2),
            ),
          ),
          children: [
            _cell('Doc', headerStyle),
            _cell('Tipo', headerStyle),
            _cell('Motivo', headerStyle),
            _cell('Gasto', headerStyle),
            _cell('Monto', headerStyle, align: pw.TextAlign.right),
          ],
        ),
        for (var i = 0; i < activeMovements.length; i++) ...[
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : PdfColors.grey50,
              border: const pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            children: [
              _cell('#${activeMovements[i].docNumber}', const pw.TextStyle(fontSize: 8.5)),
              _cell(
                activeMovements[i].type.display,
                const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
              ),
              _cell(activeMovements[i].reason, const pw.TextStyle(fontSize: 8.5)),
              _cell(
                activeMovements[i].registerAsExpense
                    ? (activeMovements[i].expenseCategory ?? 'Sí')
                    : 'No',
                const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
              _cell(
                NumberFormatter.convertToMoneyLike(activeMovements[i].amount),
                const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                align: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ],
    );
  }

  pw.Widget _cell(
    String text,
    pw.TextStyle style, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }

  pw.Widget _buildNotesBox(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'OBSERVACIONES DE CIERRE',
            style: const pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
        ],
      ),
    );
  }

  pw.Widget _buildSignaturesBlock() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _signatureColumn('Cajero / Responsable', shift.closedBy?.name ?? shift.openedBy.name),
        pw.SizedBox(width: 40),
        _signatureColumn('Supervisor / Recibido por', ''),
      ],
    );
  }

  pw.Widget _signatureColumn(String role, String name) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Container(
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            role,
            style: const pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          if (name.isNotEmpty)
            pw.Text(
              name,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, String nowStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${branch.name}  •  Arqueo de Turno #${shift.docNumber}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  final bool isTotal;
  final bool isBold;
  final bool isSubItem;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isTotal = false,
    this.isBold = false,
    this.isSubItem = false,
  });
}
