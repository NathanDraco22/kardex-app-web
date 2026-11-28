import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ProductSalesDetailTemplate implements PdfTemplate {
  final String title;
  final String branchName;
  final UserInfo? userInfo;
  final String? clientLabel;
  final ProductInDb product;
  final DateTime? startDate;
  final DateTime? endDate;
  final int invoiceCount;
  final int totalUnits;
  final int total;
  final List<InvoiceInDb> items;

  ProductSalesDetailTemplate({
    required this.title,
    required this.branchName,
    this.userInfo,
    this.clientLabel,
    required this.product,
    this.startDate,
    this.endDate,
    required this.invoiceCount,
    required this.totalUnits,
    required this.total,
    required this.items,
  });

  @override
  Future<pw.Document> buildDocument() async {
    final doc = await PdfTheme.newDocument();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSummaryInfo(),
            pw.SizedBox(height: 20),
            _buildTable(),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          "Generado el: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryInfo() {
    final startStr = startDate != null ? DateTimeTool.formatddMMyyEs(startDate!) : "Inicio";
    final endStr = endDate != null ? DateTimeTool.formatddMMyyEs(endDate!) : "Fin";
    final dateRangeStr = startStr == endStr ? startStr : "$startStr - $endStr";

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
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Sucursal: $branchName",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Producto: ${product.name}",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text("Código: ${product.displayCode}"),
              pw.SizedBox(height: 4),
              pw.Text("Usuario: ${userInfo?.name ?? 'Todos'}"),
              if (clientLabel != null && clientLabel!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text("Cliente: $clientLabel"),
              ],
              pw.SizedBox(height: 4),
              pw.Text("Periodo: $dateRangeStr"),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Total Facturas: $invoiceCount",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text("Unidades base: $totalUnits"),
              pw.SizedBox(height: 4),
              pw.Text(
                "Monto Total: ${NumberFormatter.convertToMoneyLike(total)}",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTable() {
    if (items.isEmpty) {
      return pw.Center(
        child: pw.Text("No hay ventas del producto para mostrar en este reporte."),
      );
    }

    return BasicPdfTableListView(
      itemCount: items.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Hora/Fecha", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Factura", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cliente", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 3,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cantidad", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 1,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Importe", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey200;
        final invoice = items[index];
        final productLine = invoice.productLine(product.id);
        final createdAt = invoice.createdAt;

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(
              content: pw.Text(
                "${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            BasicPdfTableCell(
              content: pw.Text(
                "#${invoice.docNumber}",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            BasicPdfTableCell(
              content: pw.Text(
                invoice.clientInfo.name,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            BasicPdfTableCell(
              content: pw.Text(
                productLine.quantityText,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            BasicPdfTableCell(
              content: pw.Text(
                NumberFormatter.convertFromCentsToUnitsCurrency(productLine.total),
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        );
      },
    );
  }
}
