import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printCreditNote(
  CreditNoteInDb creditNote,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromCreditNote(creditNote, branch, paperSize: paperSize);
  return await PrintManager.printPdf(bytes, name: 'nota_credito_${creditNote.docNumber}.pdf', paperSize: paperSize);
}

Future<bool> shareCreditNote(
  CreditNoteInDb creditNote,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromCreditNote(creditNote, branch, paperSize: paperSize);
  return await Printing.sharePdf(bytes: bytes, filename: 'nota_credito_${creditNote.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromCreditNote(
  CreditNoteInDb creditNote,
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

  final branchImage = await branch.resolveLogoBytes();
  final logoSize = TicketSettings.logoSize(paperSize);
  final isDevolution = creditNote.type == CreditNoteType.devolution;

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
                    pw.MemoryImage(branchImage),
                    width: logoSize,
                    height: logoSize,
                  ),
                ],
              ),
            pw.Text(
              branch.name,
              style: const pw.TextStyle(
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
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                    branch.email,
                    style: pw.TextStyle(
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'NOTA DE CRÉDITO',
              style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              isDevolution ? 'MODALIDAD: POR DEVOLUCIÓN' : 'MODALIDAD: POR MONTO',
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize) - 1,
                color: PdfColors.grey700,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.Divider(color: PdfColors.grey),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Folio: #${creditNote.docNumber}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(creditNote.createdAt),
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            if (creditNote.clientInfo.name != "Sin Cliente")
              pw.Text(
                "Cliente: ${creditNote.clientId}-${creditNote.clientInfo.name}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            if (isDevolution && creditNote.originalInvoiceDocNumber.isNotEmpty)
              pw.Text(
                "Factura Origen: #${creditNote.originalInvoiceDocNumber}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

            pw.Text(
              "Estado: ${creditNote.status.display}",
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
              ),
            ),

            if (creditNote.appliedReceiptDocNumber != null && creditNote.appliedReceiptDocNumber!.isNotEmpty)
              pw.Text(
                "Aplicada en Recibo: #${creditNote.appliedReceiptDocNumber}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            pw.Text(
              "Elaborado por: ${creditNote.createdBy.name}",
              style: pw.TextStyle(
                fontSize: TicketSettings.contentFontSize(paperSize),
              ),
            ),

            if (!isDevolution || creditNote.description.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                "Motivo: ${creditNote.description.isNotEmpty ? creditNote.description : 'Ajuste comercial'}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],

            pw.Divider(color: PdfColors.grey),

            // Si es devolución con productos devueltos
            if (isDevolution && creditNote.returnedItems.isNotEmpty) ...[
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
                children: creditNote.returnedItems.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: pw.TextOverflow.clip,
                                style: pw.TextStyle(
                                  fontSize: TicketSettings.contentFontSize(paperSize),
                                ),
                              ),
                              pw.Text(
                                item.product.unitName,
                                style: pw.TextStyle(
                                  fontSize: TicketSettings.contentFontSize(paperSize) - 1,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            item.formattedDisplayQuantity,
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
                              NumberFormatter.convertFromCentsToDouble(item.price * item.conversionFactor).toString(),
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
            ],

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 100,
                  child: pw.Text(
                    'TOTAL CRÉDITO: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    currencyFormat.format(creditNote.amount / 100),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.grey),

            pw.Center(
              child: pw.Text(
                'Comprobante de Saldo a Favor',
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                  fontStyle: pw.FontStyle.italic,
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
