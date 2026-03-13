import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printInvoice(InvoiceInDb invoice, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch, paperSize: paperSize);
  return await Printing.layoutPdf(onLayout: (_) => bytes, name: 'factura_${invoice.docNumber}.pdf');
}

Future<bool> shareInvoice(InvoiceInDb invoice, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch, paperSize: paperSize);
  return await Printing.sharePdf(bytes: bytes, filename: 'factura_${invoice.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromInvoice(
  InvoiceInDb invoice,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final pdf = pw.Document();
  final NumberFormat currencyFormat = NumberFormat.currency(symbol: 'C\$');

  final pageFormat = PdfPageFormat(
    TicketSettings.ticketWidth(paperSize) * PdfPageFormat.mm,
    double.infinity,
    marginAll: TicketSettings.ticketMargin(paperSize) * PdfPageFormat.mm,
  );

  final branchImage = branch.image;

  String paymentType = invoice.paymentType == PaymentType.credit ? "CREDITO" : "CONTADO";

  final totalDiscount = invoice.saleItems.fold(
    0,
    (previousValue, element) => previousValue + element.totalDiscount,
  );

  final invoiceSubTotal = invoice.saleItems.fold(
    0,
    (element, previousValue) => previousValue.subTotal + element,
  );

  final imageSize = TicketSettings.logoSize(paperSize);
  final descriptionFlex = paperSize == PaperSize.mm80 ? 4 : 3;

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: await TicketSettings.ticketFont(paperSize),
          fontBold: await TicketSettings.ticketFontBold(paperSize),
        ),
      ),
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (branchImage != null && branchImage.isNotEmpty)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(
                    pw.MemoryImage(
                      branchImage,
                    ),
                    width: imageSize,
                    height: imageSize,
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
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
              ),
              textAlign: pw.TextAlign.center,
            ),
            if (paperSize == .mm80)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (branch.phone.isNotEmpty)
                    pw.Text(
                      "Telf: ${branch.phone}",
                      style: pw.TextStyle(
                        fontSize: TicketSettings.contentFontSize(paperSize),
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                  if (branch.email.isNotEmpty)
                    pw.Text(
                      "Email: ${branch.email}",
                      style: pw.TextStyle(
                        fontSize: TicketSettings.contentFontSize(paperSize),
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                ],
              ),

            pw.Text(
              'FACTURA',
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
                  'F# ${invoice.docNumber}',
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),

                pw.Text(
                  DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),
              ],
            ),

            pw.Text(
              paymentType,
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
              ),
            ),

            pw.SizedBox(height: 4),

            if (invoice.clientInfo.name != "Sin Cliente")
              pw.Text(
                "${invoice.clientId}-${invoice.clientInfo.name}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            if (paperSize == PaperSize.mm80 &&
                invoice.clientInfo.location != null &&
                invoice.clientInfo.location!.isNotEmpty)
              pw.Text(
                "${invoice.clientInfo.location}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            if (paperSize == PaperSize.mm80 &&
                invoice.clientInfo.address != null &&
                invoice.clientInfo.address!.isNotEmpty)
              pw.Text(
                "${invoice.clientInfo.address}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            pw.SizedBox(height: 4),

            pw.Text(
              "Facturador: ${invoice.createdBy.name}",
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
              ),
            ),

            pw.Divider(color: PdfColors.grey),

            pw.Row(
              children: [
                pw.Expanded(
                  flex: descriptionFlex,
                  child: pw.Text(
                    'Descripción',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'Cant',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                  ),
                ),
                if (paperSize == PaperSize.mm80)
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'P/U',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: TicketSettings.contentFontSize(paperSize),
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
                      fontSize: TicketSettings.contentFontSize(paperSize),
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
                        flex: descriptionFlex,
                        child: pw.Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(
                            fontSize: TicketSettings.contentFontSize(paperSize),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          item.quantity.toString(),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: TicketSettings.contentFontSize(paperSize),
                          ),
                        ),
                      ),
                      if (paperSize == PaperSize.mm80)
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            NumberFormatter.convertFromCentsToDouble(item.price).toString(),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: TicketSettings.contentFontSize(paperSize),
                            ),
                          ),
                        ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          NumberFormatter.convertFromCentsToDouble(item.subTotal).toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: TicketSettings.contentFontSize(paperSize),
                          ),
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
                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    'SUBTOTAL: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    currencyFormat.format(invoiceSubTotal / 100),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    'DESCUENTO: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    currencyFormat.format(totalDiscount / 100),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    'TOTAL: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),

                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    currencyFormat.format(invoice.total / 100),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey),

            pw.Center(
              child: pw.Text(
                '¡Gracias por su compra!',
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
