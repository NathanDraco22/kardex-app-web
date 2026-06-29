import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SingleInvoiceTemplate implements PdfTemplate {
  final InvoiceInDb invoice;
  final BranchInDb branch;

  SingleInvoiceTemplate({
    required this.invoice,
    required this.branch,
  });

  @override
  Future<pw.Document> buildDocument() async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.Divider(color: PdfColors.grey400),
            _buildTableSection(),
            pw.Divider(color: PdfColors.grey400),
            _buildTotals(),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader() {
    final branchImage = branch.image;
    String clientLabel = "${invoice.clientId} - ${invoice.clientInfo.name}";
    if (invoice.clientId == "SALE_CLIENT") {
      clientLabel = invoice.clientInfo.name;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                      width: 60,
                      height: 60,
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          branch.name,
                          style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          branch.address,
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Tel: ${branch.phone} | Email: ${branch.email}",
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
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
                pw.Text(
                  "FACTURA",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "No. ${invoice.docNumber}",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "${DateTimeTool.formatddMMyy(invoice.createdAt)} ${DateTimeTool.formatHHmm(invoice.createdAt)}",
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "CLIENTE",
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      clientLabel,
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    if (invoice.clientInfo.location != null && invoice.clientInfo.location!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${invoice.clientInfo.location}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    if (invoice.clientInfo.address != null && invoice.clientInfo.address!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${invoice.clientInfo.address}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Vendedor: ${invoice.createdBy.name}",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "DETALLES",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 4),
                  _buildPaymentType(),
                  if (invoice.description.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Observación: ${invoice.description}",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentType() {
    final label = pw.Text(
      invoice.paymentType.typeLabel,
      style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    );

    if (invoice.paymentType == PaymentType.card || invoice.paymentType == PaymentType.transfer) {
      return pw.Row(
        children: [
          label,
          pw.Text(
            " - Ref: ${invoice.bankReference}",
            style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      );
    }

    return label;
  }

  pw.Widget _buildTableSection() {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Text("Producto", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  "Cant.",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Precio",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Total",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(invoice.saleItems.length, (index) {
          final saleItem = invoice.saleItems[index];
          final isOdd = index % 2 != 0;
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            color: isOdd ? PdfColors.white : PdfColors.grey100,
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(saleItem.product.name, style: const pw.TextStyle(fontSize: 12)),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    saleItem.quantity.toString(),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertFromCentsToDouble(saleItem.price).toString(),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertFromCentsToDouble(saleItem.subTotal).toString(),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildTotals() {
    final totalDiscount = invoice.saleItems.fold<int>(
      0,
      (previousValue, element) => previousValue + element.totalDiscount,
    );
    final invoiceSubTotal = invoice.saleItems.fold<int>(
      0,
      (previousValue, element) => previousValue + element.subTotal,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text("SubTotal:", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(
                width: 110,
                child: pw.Text(
                  NumberFormatter.convertToMoneyLike(invoiceSubTotal),
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text("Total Descuento:", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(
                width: 110,
                child: pw.Text(
                  NumberFormatter.convertToMoneyLike(totalDiscount),
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text("Total:", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(invoice.total),
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
