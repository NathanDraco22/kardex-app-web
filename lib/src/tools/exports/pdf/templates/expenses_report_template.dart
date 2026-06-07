import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExpensesReportTemplate implements PdfTemplate {
  final String title;
  final String branchName;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ExpenseInDb> items;

  ExpensesReportTemplate({
    required this.title,
    required this.branchName,
    this.startDate,
    this.endDate,
    required this.items,
  });

  @override
  Future<pw.Document> buildDocument() async {
    final doc = pw.Document();

    // Lógica de consolidación
    final operativeExpenses = items.where((e) => e.type == ExpenseType.operative).toList();
    final supplierExpenses = items.where((e) => e.type == ExpenseType.supplier).toList();

    final Map<String, int> operativeByCategory = {};
    int totalOperative = 0;
    for (final e in operativeExpenses) {
      operativeByCategory[e.category] = (operativeByCategory[e.category] ?? 0) + e.amount;
      totalOperative += e.amount;
    }

    final Map<String, int> supplierBySupplierName = {};
    int totalSupplier = 0;
    for (final e in supplierExpenses) {
      final name = e.supplierName.isEmpty ? 'Desconocido' : e.supplierName;
      supplierBySupplierName[name] = (supplierBySupplierName[name] ?? 0) + e.amount;
      totalSupplier += e.amount;
    }

    final grandTotal = totalOperative + totalSupplier;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 15),
            _buildSummaryInfo(totalOperative, totalSupplier, grandTotal),
            pw.SizedBox(height: 20),
            _buildConsolidatedSection(operativeByCategory, supplierBySupplierName),
            pw.SizedBox(height: 20),
            pw.Text(
              "Listado Detallado de Gastos",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
            ),
            pw.SizedBox(height: 8),
            _buildDetailedTable(),
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
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "Sucursal: $branchName",
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "Generado el: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryInfo(int totalOperative, int totalSupplier, int grandTotal) {
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
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Periodo: $dateRangeStr", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Gastos Operativos:", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    NumberFormatter.convertToMoneyLike(totalOperative),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Gastos a Proveedores:", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    NumberFormatter.convertToMoneyLike(totalSupplier),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Gran Total Gastos:", style: const pw.TextStyle(fontSize: 10, color: PdfColors.red700)),
                  pw.Text(
                    NumberFormatter.convertToMoneyLike(grandTotal),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.red700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildConsolidatedSection(
    Map<String, int> operativeByCategory,
    Map<String, int> supplierBySupplierName,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Consolidado Operativo",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
              ),
              pw.SizedBox(height: 6),
              if (operativeByCategory.isEmpty)
                pw.Text("Sin gastos operativos", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
              else
                _buildConsolidationTable(operativeByCategory, "Categoría"),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Consolidado Proveedores",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
              ),
              pw.SizedBox(height: 6),
              if (supplierBySupplierName.isEmpty)
                pw.Text("Sin gastos a proveedores", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
              else
                _buildConsolidationTable(supplierBySupplierName, "Proveedor"),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildConsolidationTable(Map<String, int> data, String nameHeader) {
    final list = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(nameHeader, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
              ),
            ),
          ],
        ),
        ...list.map((entry) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(NumberFormatter.convertToMoneyLike(entry.value), style: const pw.TextStyle(fontSize: 8)),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildDetailedTable() {
    if (items.isEmpty) {
      return pw.Center(
        child: pw.Text("No hay gastos para mostrar en este reporte.", style: const pw.TextStyle(fontSize: 10)),
      );
    }

    return BasicPdfTableListView(
      itemCount: items.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Fecha", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Tipo", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Documento", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Concepto", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 3,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Estado", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Monto", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey100;
        final expense = items[index];

        final dateFormatted = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(expense.date));
        final typeStr = expense.type == ExpenseType.operative ? "Operativo" : "Proveedor";
        final concept = expense.type == ExpenseType.operative ? expense.category : expense.supplierName;
        final totalFormatted = NumberFormatter.convertToMoneyLike(expense.amount);

        String statusStr = "";
        switch (expense.status) {
          case ExpenseStatus.draft:
            statusStr = "Borrador";
            break;
          case ExpenseStatus.open:
            statusStr = "Pendiente";
            break;
          case ExpenseStatus.paid:
            statusStr = "Pagado";
            break;
          case ExpenseStatus.partiallyPaid:
            statusStr = "Parcial";
            break;
          case ExpenseStatus.cancelled:
            statusStr = "Cancelado";
            break;
        }

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(dateFormatted, style: const pw.TextStyle(fontSize: 8))),
            BasicPdfTableCell(content: pw.Text(typeStr, style: const pw.TextStyle(fontSize: 8))),
            BasicPdfTableCell(content: pw.Text(expense.docNumber, style: const pw.TextStyle(fontSize: 8))),
            BasicPdfTableCell(content: pw.Text(concept, style: const pw.TextStyle(fontSize: 8))),
            BasicPdfTableCell(content: pw.Text(statusStr, style: const pw.TextStyle(fontSize: 8))),
            BasicPdfTableCell(content: pw.Text(totalFormatted, style: const pw.TextStyle(fontSize: 8))),
          ],
        );
      },
    );
  }
}
