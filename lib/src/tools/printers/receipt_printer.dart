import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketSettings {
  static double get titleFontSize => 8.5;
  static double get contentFontSize => 9;
}

Future<bool> printReceipt(ReceiptInDb receipt, BranchInDb branch) async {
  final bytes = await generateTicketPdfFromReceipt(receipt, branch);
  return await Printing.layoutPdf(onLayout: (_) => bytes, name: 'recibo_${receipt.docNumber}.pdf');
}

Future<bool> shareReceipt(ReceiptInDb receipt, BranchInDb branch) async {
  final bytes = await generateTicketPdfFromReceipt(receipt, branch);
  return await Printing.sharePdf(bytes: bytes, filename: 'recibo_${receipt.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromReceipt(ReceiptInDb receipt, BranchInDb branch) async {
  final pdf = pw.Document();
  final NumberFormat currencyFormat = NumberFormat.currency(symbol: 'C\$');

  const pageFormat = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 2.5 * PdfPageFormat.mm,
  );

  final branchImage = branch.image;

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (branchImage != null && branchImage.isNotEmpty)
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Image(pw.MemoryImage(branchImage), width: 100, height: 100),
              ),

            pw.Text(
              branch.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              branch.address,
              style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
              textAlign: pw.TextAlign.center,
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Telf: ${branch.phone}", style: pw.TextStyle(fontSize: TicketSettings.contentFontSize)),
                pw.Text("Email: ${branch.email}", style: pw.TextStyle(fontSize: TicketSettings.contentFontSize)),
              ],
            ),
            pw.Divider(color: PdfColors.grey),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Recibo: ${receipt.docNumber}', style: pw.TextStyle(fontSize: TicketSettings.contentFontSize)),
                pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(receipt.createdAt)}',
                  style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            if (receipt.clientInfo.name != "Sin Cliente")
              pw.Text(
                'Cliente: ${receipt.clientInfo.name}',
                style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
              ),
            pw.Divider(color: PdfColors.grey),
            pw.Text(
              'Elaborado por: ${receipt.createdBy.name}',
              style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
            ),
            pw.Divider(color: PdfColors.grey),

            pw.Text(
              'Detalles del Pago',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Factura',
                  style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                ),
                pw.Text(
                  "Monto",
                  style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey800),
            pw.Column(
              children: receipt.appliedInvoices.map((invoice) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '#${invoice.docNumber}',
                        style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                      ),
                      pw.Text(
                        NumberFormatter.convertToMoneyLike(invoice.amountApplied),
                        style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            pw.Divider(color: PdfColors.grey800),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL RECIBO: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                ),
                pw.Text(
                  currencyFormat.format(receipt.total / 100),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey),

            pw.Center(
              child: pw.Text(
                '¡Gracias!',
                style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
