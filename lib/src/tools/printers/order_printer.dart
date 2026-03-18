import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printOrder(OrderInDb order, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromOrder(order, branch, paperSize: paperSize);
  return await Printing.layoutPdf(onLayout: (_) => bytes, name: 'pedido_${order.docNumber}.pdf');
}

Future<bool> shareOrder(OrderInDb order, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
  final bytes = await generateTicketPdfFromOrder(order, branch, paperSize: paperSize);
  return await Printing.sharePdf(bytes: bytes, filename: 'pedido_${order.docNumber}.pdf');
}

Future<Uint8List> generateTicketPdfFromOrder(
  OrderInDb order,
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

  String paymentType = order.paymentType.typeLabel;

  final totalDiscount = order.saleItems.fold(
    0,
    (previousValue, element) => previousValue + element.totalDiscount,
  );

  final orderSubTotal = order.saleItems.fold(
    0,
    (element, previousValue) => previousValue.subTotal + element,
  );

  final logoSize = TicketSettings.logoSize(paperSize);
  final descriptionFlex = paperSize == PaperSize.mm80 ? 4 : 3;

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
              'PEDIDO',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.Divider(color: PdfColors.grey),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Pedido: ${order.docNumber}',
                  style: pw.TextStyle(
                    fontSize: TicketSettings.contentFontSize(paperSize),
                  ),
                ),

                pw.Text(
                  DateFormat('dd/MM/yyyy').format(order.createdAt),
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

            pw.SizedBox(height: 6),

            if (order.clientInfo.name != "Sin Cliente")
              pw.Text(
                "${order.clientId}-${order.clientInfo.name}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            if (paperSize == PaperSize.mm80 &&
                order.clientInfo.location != null &&
                order.clientInfo.location!.isNotEmpty)
              pw.Text(
                "${order.clientInfo.location}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            if (paperSize == PaperSize.mm80 && order.clientInfo.address != null && order.clientInfo.address!.isNotEmpty)
              pw.Text(
                "${order.clientInfo.address}",
                style: pw.TextStyle(
                  fontSize: TicketSettings.contentFontSize(paperSize),
                ),
              ),

            pw.Text(
              "Elaborado por: ${order.createdBy.name}",
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
              children: order.saleItems.map((item) {
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
                  width: 70,
                  child: pw.Text(
                    currencyFormat.format(orderSubTotal / 100),
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
                  width: 70,
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
                  width: 70,
                  child: pw.Text(
                    currencyFormat.format(order.total / 100),
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
                '¡Gracias por su preferencia!',
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
