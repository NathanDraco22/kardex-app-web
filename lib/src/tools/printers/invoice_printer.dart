import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printInvoice(InvoiceInDb invoice, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch, paperSize: paperSize);
  return await PrintManager.printPdf(bytes, name: 'factura_${invoice.docNumber}.pdf', paperSize: paperSize);
}

Future<bool> shareInvoice(InvoiceInDb invoice, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromInvoice(invoice, branch, paperSize: paperSize);
  return await Printing.sharePdf(bytes: bytes, filename: 'factura_${invoice.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromInvoice(
  InvoiceInDb invoice,
  BranchInDb branch, {
  PaperSize paperSize = PaperSize.mm80,
  double? extraRightMarginMm,
}) async {
  final pdf = pw.Document();
  final NumberFormat currencyFormat = NumberFormatter.currencyFormat;

  final pageFormat = await PrintManager.getTicketPageFormat(
    paperSize,
    extraRightMarginMm: extraRightMarginMm,
  );

  final branchImage = await branch.resolveLogoBytes();

  String paymentType = invoice.paymentType == PaymentType.credit ? "CREDITO" : "CONTADO";

  final itemDiscounts = invoice.effectiveItemDiscounts;
  final invoiceDiscount = invoice.invoiceDiscount;
  final totalDiscount = invoice.totalDiscount;
  final pctLabel =
      invoice.discountType == DiscountType.percentage && invoice.discountValue > 0
          ? '${invoice.discountValue}%'
          : DiscountType.formatEquivalentPercentage(
              discountAmount: invoiceDiscount,
              baseAmount: invoice.itemsNetTotal,
            );
  final invoiceDiscountTag = pctLabel.isNotEmpty ? ' ($pctLabel)' : '';

  final invoiceSubTotal = invoice.itemsSubTotal;

  final secondaryTotal = NumberFormatter.convertInvoiceTotalToSecondaryMoney(invoice.total);
  final secondaryCurrency = NumberFormatter.secondaryCurrency;

  final imageSize = TicketSettings.logoSize(paperSize);
  final descriptionFlex = paperSize == PaperSize.mm80 ? 4 : 3;

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: await TicketSettings.ticketFont(paperSize),
          fontBold: await TicketSettings.ticketFontBold(paperSize),
          fontFallback: [await TicketSettings.ticketFallbackFont()],
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
              style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
            if (branch.formattedRuc != null)
              pw.Text(
                branch.formattedRuc!,
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
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

            pw.Text(
              'FACTURA',
              style: const pw.TextStyle(
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

            if (invoice.orderInfo != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Pedido: ${invoice.orderInfo!.docNumber}',
                    style: pw.TextStyle(
                      fontSize: TicketSettings.contentFontSize(paperSize),
                    ),
                  ),
                  pw.Text(
                    'Ped: ${DateFormat('dd/MM/yyyy').format(invoice.orderInfo!.createdAt)}',
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
              "Vendedor: ${invoice.createdBy.name}",
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
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.product.name,
                              maxLines: 3,
                              overflow: pw.TextOverflow.clip,
                              style: pw.TextStyle(
                                fontSize: TicketSettings.contentFontSize(paperSize),
                              ),
                            ),
                            pw.Text(
                              item.displayUnitName,
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
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              item.formattedDisplayQuantity,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: TicketSettings.contentFontSize(paperSize),
                              ),
                            ),
                            if (item.bonQuantity > 0)
                              pw.Text(
                                "+ ${item.formattedDisplayBonQuantity} bonif.",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: TicketSettings.contentFontSize(paperSize) - 1,
                                  color: PdfColors.grey700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (paperSize == PaperSize.mm80)
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            NumberFormatter.convertFromCentsToDouble(item.displayUnitPrice).toString(),
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

            if (invoiceDiscount > 0) ...[
              if (itemDiscounts > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 68,
                      child: pw.Text(
                        'DESC. PROD: ',
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
                        currencyFormat.format(itemDiscounts / 100),
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
                    width: 68,
                    child: pw.Text(
                      'DESC. FACT$invoiceDiscountTag: ',
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
                      currencyFormat.format(invoiceDiscount / 100),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: TicketSettings.contentFontSize(paperSize),
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ] else
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
            if (secondaryTotal != null && secondaryCurrency != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text(
                      'Total(${secondaryCurrency.code}): ',
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
                      secondaryTotal,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: TicketSettings.contentFontSize(paperSize),
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            if (invoice.paymentDetail != null) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Pagó con: ${invoice.paymentDetail!.formatTenderedLabel(NumberFormatter.currency)}',
                    style: pw.TextStyle(
                      fontSize: TicketSettings.contentFontSize(paperSize) - 1,
                    ),
                  ),
                ],
              ),
              if (invoice.paymentDetail!.changeAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Cambio: ${invoice.paymentDetail!.formatChangeLabel(NumberFormatter.currency)}',
                      style: pw.TextStyle(
                        fontSize: TicketSettings.contentFontSize(paperSize) - 1,
                      ),
                    ),
                  ],
                ),
            ],
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
