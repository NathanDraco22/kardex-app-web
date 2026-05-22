import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SingleReceiptTemplate implements PdfTemplate {
  final ReceiptInDb receipt;
  final BranchInDb branch;

  SingleReceiptTemplate({
    required this.receipt,
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
            _buildAppliedInvoicesSection(),
            if (receipt.appliedDevolutions.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _buildAppliedDevolutionsSection(),
            ],
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
    String clientLabel = "${receipt.clientId} - ${receipt.clientInfo.name}";
    if (receipt.clientId == "SALE_CLIENT") {
      clientLabel = receipt.clientInfo.name;
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
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
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
                  "RECIBO OFICIAL",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.teal800),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "No. ${receipt.docNumber}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "${DateTimeTool.formatddMMyy(receipt.createdAt)} ${DateTimeTool.formatHHmm(receipt.createdAt)}",
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
                      "RECIBIDO DE",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      clientLabel,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    if (receipt.clientInfo.location != null && receipt.clientInfo.location!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${receipt.clientInfo.location}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    if (receipt.clientInfo.address != null && receipt.clientInfo.address!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${receipt.clientInfo.address}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Cobrado por: ${receipt.createdBy.name}",
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
                    "DETALLES DE PAGO",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Método: ${receipt.paymentMethod.display}",
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  if (receipt.bankReference.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Ref: ${receipt.bankReference}",
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

  pw.Widget _buildAppliedInvoicesSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "FACTURAS APLICADAS",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.teal800),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text("Número de Factura", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Monto Aplicado",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(receipt.appliedInvoices.length, (index) {
          final inv = receipt.appliedInvoices[index];
          final isOdd = index % 2 != 0;
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            color: isOdd ? PdfColors.white : PdfColors.grey100,
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text("Factura #${inv.docNumber}", style: const pw.TextStyle(fontSize: 11)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(inv.amountApplied),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildAppliedDevolutionsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "DEVOLUCIONES APLICADAS",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.red800),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text("Número de Devolución", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Monto Aplicado",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(receipt.appliedDevolutions.length, (index) {
          final dev = receipt.appliedDevolutions[index];
          final isOdd = index % 2 != 0;
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            color: isOdd ? PdfColors.white : PdfColors.grey100,
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text("Devolución #${dev.docNumber}", style: const pw.TextStyle(fontSize: 11)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(dev.amountApplied),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text("Total Recibido:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(receipt.total),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
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
