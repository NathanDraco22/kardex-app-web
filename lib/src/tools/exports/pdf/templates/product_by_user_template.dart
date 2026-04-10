import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ProductByUserTemplate implements PdfTemplate {
  final String title;
  final String branchName;
  final UserInfo? userInfo;
  final DateTime? startDate;
  final DateTime? endDate;
  final int count;
  final int total;
  final List<ProductSalesTotal> items;

  ProductByUserTemplate({
    required this.title,
    required this.branchName,
    this.userInfo,
    this.startDate,
    this.endDate,
    required this.count,
    required this.total,
    required this.items,
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
          style: pw.TextStyle(
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
    String dateRangeStr = "$startStr - $endStr";
    if (startDate != null && endDate == null) {
      dateRangeStr = startStr;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Sucursal: $branchName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text("Usuario: ${userInfo?.name ?? 'Todos'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text("Periodo: $dateRangeStr"),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("Total Productos: $count", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                "Monto Total: ${NumberFormatter.convertToMoneyLike(total)}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
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
        child: pw.Text("No hay productos para mostrar en este reporte."),
      );
    }

    return BasicPdfTableListView(
      itemCount: items.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Producto", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          flex: 3,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cantidad", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Importe", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey200;
        final productSale = items[index];

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(productSale.productName)),
            BasicPdfTableCell(content: pw.Text(productSale.totalUnits.toString())),
            BasicPdfTableCell(content: pw.Text(NumberFormatter.convertToMoneyLike(productSale.total))),
          ],
        );
      },
    );
  }
}
