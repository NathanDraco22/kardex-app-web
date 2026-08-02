import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceReceiptsHistoryTemplate implements PdfTemplate {
  final InvoiceInDb invoice;
  final List<ReceiptInDb> receipts;
  final BranchInDb branch;

  InvoiceReceiptsHistoryTemplate({
    required this.invoice,
    required this.receipts,
    required this.branch,
  });

  int get _totalApplied {
    var total = 0;
    for (final receipt in receipts) {
      total += receipt.appliedInvoices
          .where((applied) => applied.invoiceId == invoice.id)
          .fold(0, (sum, applied) => sum + applied.amountApplied);
    }
    return total;
  }

  int _amountAppliedToInvoice(ReceiptInDb receipt) {
    return receipt.appliedInvoices
        .where((applied) => applied.invoiceId == invoice.id)
        .fold(0, (sum, applied) => sum + applied.amountApplied);
  }

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
            pw.SizedBox(height: 16),
            _buildInvoiceSummary(),
            pw.SizedBox(height: 20),
            _buildReceiptsTable(),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader() {
    final branchImage = branch.image;

    return pw.Row(
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
              "HISTORIAL DE ABONOS",
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.teal800),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "Factura #${invoice.docNumber}",
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              "Generado el: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceSummary() {
    final totalApplied = _totalApplied;
    final totalRemaining = invoice.total - totalApplied;

    return pw.Container(
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
                  "${invoice.clientId} - ${invoice.clientInfo.name}",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Factura del: ${DateTimeTool.formatddMMyyEs(invoice.createdAt)}",
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
                "Total Factura: ${NumberFormatter.convertToMoneyLike(invoice.total)}",
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "Total Abonos: ${NumberFormatter.convertToMoneyLike(totalApplied)}",
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "Saldo Restante: ${NumberFormatter.convertToMoneyLike(totalRemaining)}",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: totalRemaining > 0 ? PdfColors.red800 : PdfColors.green800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReceiptsTable() {
    if (receipts.isEmpty) {
      return pw.Center(
        child: pw.Text("No hay abonos registrados para esta factura."),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          "DETALLE DE ABONOS",
          style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.teal800),
        ),
        pw.SizedBox(height: 6),
        BasicPdfTableListView(
          itemCount: receipts.length,
          columns: [
            BasicPdfTableColumn(
              label: pw.Text("Fecha/Hora", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              flex: 2,
            ),
            BasicPdfTableColumn(
              label: pw.Text("Recibo", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              flex: 2,
            ),
            BasicPdfTableColumn(
              label: pw.Text("Método", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              flex: 2,
            ),
            BasicPdfTableColumn(
              label: pw.Text("Monto Aplicado", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              flex: 2,
            ),
          ],
          rowBuilder: (context, index) {
            final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey200;
            final receipt = receipts[index];
            final createdAt = receipt.createdAt;

            return BasicPdfTableRow(
              color: rowColor,
              cells: [
                BasicPdfTableCell(
                  content: pw.Text(
                    "${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                BasicPdfTableCell(
                  content: pw.Text("#${receipt.docNumber}", style: const pw.TextStyle(fontSize: 10)),
                ),
                BasicPdfTableCell(
                  content: pw.Text(receipt.paymentMethod.display, style: const pw.TextStyle(fontSize: 10)),
                ),
                BasicPdfTableCell(
                  content: pw.Text(
                    NumberFormatter.convertToMoneyLike(_amountAppliedToInvoice(receipt)),
                    style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                "Total Abonos:",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.SizedBox(
                width: 120,
                child: pw.Text(
                  NumberFormatter.convertToMoneyLike(_totalApplied),
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
