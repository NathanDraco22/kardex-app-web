import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceByUserTemplate implements PdfTemplate {
  final String title;
  final UserInfo? userInfo;
  final DateTime? startDate;
  final DateTime? endDate;
  final int count;
  final int total;
  final List<InvoiceInDb> items;

  InvoiceByUserTemplate({
    required this.title,
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
    String dateRangeStr = startStr == endStr ? startStr : "$startStr - $endStr";
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
              pw.Text("Usuario: ${userInfo?.name ?? 'Todos'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text("Periodo: $dateRangeStr"),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("Total Facturas: $count", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
        child: pw.Text("No hay facturas para mostrar en este reporte."),
      );
    }

    return BasicPdfTableListView(
      itemCount: items.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Hora/Fecha", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Factura", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cliente", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 3,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Monto pagado", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey200;
        final currentInvoice = items[index];

        final paidDate = currentInvoice.paidAt ?? DateTime.now();
        final paidAtFormatted = "${DateTimeTool.formatddMMyy(paidDate)} ${DateTimeTool.formatHHmm(paidDate)}";
        final clientName = currentInvoice.clientInfo.name;
        final totalPaid = NumberFormatter.convertToMoneyLike(currentInvoice.total);

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(paidAtFormatted, style: const pw.TextStyle(fontSize: 10))),
            BasicPdfTableCell(content: pw.Text("#${currentInvoice.docNumber}", style: const pw.TextStyle(fontSize: 10))),
            BasicPdfTableCell(content: pw.Text(clientName, style: const pw.TextStyle(fontSize: 10))),
            BasicPdfTableCell(content: pw.Text(totalPaid, style: const pw.TextStyle(fontSize: 10))),
          ],
        );
      },
    );
  }
}
