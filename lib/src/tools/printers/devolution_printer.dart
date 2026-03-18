import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printDevolution(
  DevolutionInDb devolution,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromDevolution(devolution, branch, paperSize: paperSize);
  return await Printing.layoutPdf(onLayout: (_) => bytes, name: 'devolucion_${devolution.docNumber}.pdf');
}

Future<bool> shareDevolution(
  DevolutionInDb devolution,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromDevolution(devolution, branch, paperSize: paperSize);
  return await Printing.sharePdf(bytes: bytes, filename: 'devolucion_${devolution.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromDevolution(
  DevolutionInDb devolution,
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

  final logoSize = TicketSettings.logoSize(paperSize);

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: await TicketSettings.ticketFont(paperSize),
          fontBold: await TicketSettings.ticketFontBold(paperSize),
        ),
      ),
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
                    width: logoSize,
                    height: logoSize,
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
              'DEVOLUCIÓN',
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
                  'Devolución: ${devolution.docNumber}',
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),

                pw.Text(
                  DateFormat('dd/MM/yyyy').format(devolution.createdAt),
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 6),

            if (devolution.clientInfo.name != "Sin Cliente")
              pw.Text(
                "${devolution.clientId}-${devolution.clientInfo.name}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            pw.Text(
              "Elaborado por: ${devolution.createdBy.name}",
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
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
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'Cant.',
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
              children: devolution.returnedItems.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
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
                  width: 80,
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
                  width: 70,
                  child: pw.Text(
                    currencyFormat.format(devolution.total / 100),
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
                'Documento de Devolución',
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
