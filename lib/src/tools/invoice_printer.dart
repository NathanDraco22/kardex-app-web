import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printInvoice(InvoiceInDb invoice, BranchInDb branch) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch);
  return await Printing.layoutPdf(onLayout: (_) => bytes, name: 'factura_${invoice.docNumber}.pdf');
}

Future<bool> shareInvoice(InvoiceInDb invoice, BranchInDb branch) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch);
  return await Printing.sharePdf(bytes: bytes, filename: 'factura_${invoice.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromInvoice(InvoiceInDb invoice, BranchInDb branch) async {
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
            if (branchImage != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(
                    pw.MemoryImage(
                      branchImage,
                    ),
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            pw.Text(
              branch.name,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              branch.address,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Telf: ${branch.phone}",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.Text(
                  "Email: ${branch.email}",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),

            pw.Divider(color: PdfColors.grey),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Factura:',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      invoice.docNumber,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'Fecha:',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 6),

            pw.Text(
              'Cliente: Nombre del cliente',
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
            pw.Divider(color: PdfColors.grey),

            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Descripción',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'Cant.',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Total',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey800),

            pw.Column(
              children: invoice.saleItems.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          item.product.name,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          NumberFormatter.convertToMoneyLike(item.subTotal),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
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
                  'TOTAL: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  currencyFormat.format(invoice.total / 100),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey),

            pw.Center(
              child: pw.Text(
                '¡Gracias por su compra!',
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: invoice.id,
                width: 60,
                height: 60,
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
