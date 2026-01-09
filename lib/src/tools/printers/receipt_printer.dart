import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  final pageFormat = PdfPageFormat(
    TicketSettings.ticketWidth * PdfPageFormat.mm,
    double.infinity,
    marginAll: TicketSettings.ticketMargin * PdfPageFormat.mm,
  );

  final branchImage = branch.image;

  final totalInvoice = receipt.appliedInvoices.fold(
    0,
    (previousValue, element) => previousValue + element.amountApplied,
  );
  final totalDevolution = receipt.appliedDevolutions.fold(
    0,
    (previousValue, element) => previousValue + element.amountApplied,
  );

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
                pw.Text(
                  "Telf: ${branch.phone}",
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize,
                  ),
                ),
                pw.Text(
                  "Email: ${branch.email}",
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize,
                  ),
                ),
              ],
            ),

            pw.Text(
              'Recibo',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.Divider(color: PdfColors.grey),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Recibo: ${receipt.docNumber}',
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize,
                  ),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(receipt.createdAt),
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
            pw.Text(
              'Elaborado por: ${receipt.createdBy.name}',
              style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
            ),
            pw.Divider(color: PdfColors.grey),

            pw.Text(
              'Detalles del Pago',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
            ),
            pw.Divider(color: PdfColors.grey800),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Fact.',
                  style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                ),
                pw.Text(
                  "Monto",
                  style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                ),
              ],
            ),

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
            if (receipt.appliedDevolutions.isNotEmpty) pw.Divider(color: PdfColors.grey800),

            if (receipt.appliedDevolutions.isNotEmpty)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Devol.',
                    style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                  ),
                  pw.Text(
                    "Monto",
                    style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                  ),
                ],
              ),
            pw.Column(
              children: receipt.appliedDevolutions.map((devolution) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '#${devolution.docNumber}',
                        style: pw.TextStyle(fontSize: TicketSettings.contentFontSize),
                      ),
                      pw.Text(
                        NumberFormatter.convertToMoneyLike(devolution.amountApplied),
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
                  'Facts: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                ),

                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(totalInvoice),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Devol.: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                ),

                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(totalDevolution),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                ),

                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(receipt.total),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: TicketSettings.contentFontSize),
                    textAlign: pw.TextAlign.right,
                  ),
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
