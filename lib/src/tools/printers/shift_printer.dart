import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printShiftTicket(
  BaseShift shift,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateShiftTicketPdf(shift, branch, paperSize: paperSize);
  return await PrintManager.printPdf(
    bytes,
    name: 'turno_${shift.docNumber}.pdf',
    paperSize: paperSize,
  );
}

Future<bool> shareShiftTicket(
  BaseShift shift,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateShiftTicketPdf(shift, branch, paperSize: paperSize);
  return await Printing.sharePdf(
    bytes: bytes,
    filename: 'turno_${shift.docNumber}.pdf',
  );
}

Future<Uint8List> generateShiftTicketPdf(
  BaseShift shift,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final pdf = pw.Document();
  final pageFormat = PdfPageFormat(
    TicketSettings.ticketWidth(paperSize) * PdfPageFormat.mm,
    double.infinity,
    marginAll: TicketSettings.ticketMargin(paperSize) * PdfPageFormat.mm,
  );

  final branchImage = await branch.resolveLogoBytes();
  final logoSize = TicketSettings.logoSize(paperSize);
  final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
  final openedAt = DateTime.fromMillisecondsSinceEpoch(shift.openedAt);
  final closedAt = (shift is ShiftInDb && shift.closedAt != null)
      ? DateTime.fromMillisecondsSinceEpoch(shift.closedAt!)
      : null;

  pw.Widget rowLine(String label, int amount, {bool bold = false, String prefix = ''}) {
    final style = pw.TextStyle(
      fontSize: TicketSettings.contentFontSize(paperSize),
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text('$prefix${NumberFormatter.convertToMoneyLike(amount)}', style: style),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (branchImage != null && branchImage.isNotEmpty)
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(branchImage),
                height: logoSize,
                fit: pw.BoxFit.contain,
              ),
            ),
          pw.SizedBox(height: 6),
          pw.Text(
            branch.name.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: TicketSettings.titleFontSize(paperSize),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'CORTE DE TURNO #${shift.docNumber}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: TicketSettings.contentFontSize(paperSize),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Estado: ${shift.status.display}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: TicketSettings.contentFontSize(paperSize)),
          ),
          pw.Divider(),
          pw.Text(
            'Cajero: ${shift.openedBy.name}',
            style: pw.TextStyle(fontSize: TicketSettings.contentFontSize(paperSize)),
          ),
          pw.Text(
            'Apertura: ${dateFormat.format(openedAt)}',
            style: pw.TextStyle(fontSize: TicketSettings.contentFontSize(paperSize)),
          ),
          if (closedAt != null)
            pw.Text(
              'Cierre: ${dateFormat.format(closedAt)}',
              style: pw.TextStyle(fontSize: TicketSettings.contentFontSize(paperSize)),
            ),
          pw.Divider(),
          pw.Text(
            'CAJA FÍSICA (EFECTIVO)',
            style: pw.TextStyle(
              fontSize: TicketSettings.contentFontSize(paperSize),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          rowLine('Fondo inicial', shift.initialCash, prefix: '+'),
          rowLine('Facturas efectivo (${shift.invoiceCount})', shift.invoiceCashTotal, prefix: '+'),
          rowLine('Recibos efectivo (${shift.receiptCount})', shift.receiptCashTotal, prefix: '+'),
          rowLine('Entradas de caja', shift.cashInTotal, prefix: '+'),
          rowLine('Devoluciones (${shift.devolutionCount})', shift.devolutionTotal, prefix: '-'),
          rowLine('Salidas / Gastos', shift.cashOutTotal, prefix: '-'),
          pw.Divider(),
          rowLine('Efectivo esperado', shift.expectedCash, bold: true),
          if (shift.status == ShiftStatus.closed) ...[
            rowLine('Efectivo contado', shift.countedCash, bold: true),
            rowLine('Diferencia', shift.cashDifference, bold: true),
          ],
          pw.Divider(),
          pw.Text(
            'OTROS MEDIOS Y CONSOLIDADO',
            style: pw.TextStyle(
              fontSize: TicketSettings.contentFontSize(paperSize),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          rowLine('Transferencias', shift.totalTransfers),
          rowLine('Tarjetas y otros', shift.totalCardsAndOthers),
          rowLine('Ventas a crédito', shift.invoiceCreditTotal),
          rowLine('Notas de crédito (${shift.creditNoteCount})', shift.creditNoteTotal),
          pw.Divider(),
          rowLine('TOTAL GENERAL', shift.grandTotal, bold: true),
          if (shift.closingNotes.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Notas: ${shift.closingNotes}',
              style: pw.TextStyle(fontSize: TicketSettings.contentFontSize(paperSize)),
            ),
          ],
          pw.SizedBox(height: 12),
        ],
      ),
    ),
  );

  return pdf.save();
}
