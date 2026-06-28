import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CurrentInventoryTemplate implements PdfTemplate {
  final String title;
  final String branchName;
  final List<InventoryInDb> items;
  final int total;

  CurrentInventoryTemplate({
    required this.title,
    required this.branchName,
    required this.items,
    required this.total,
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
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
          textAlign: pw.TextAlign.center,
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
            children: [
              pw.Text(
                "Sucursal: $branchName",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.Text(
                "Generado el: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableSection() {
    if (items.isEmpty) {
      return pw.Center(
        child: pw.Text("No hay resultados para mostrar."),
      );
    }

    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Text("Producto", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  "Stock",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Costo Promedio",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Total",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final product = item.product;
          final isOdd = index % 2 != 0;
          
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            color: isOdd ? PdfColors.white : PdfColors.grey100,
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(product.name, style: const pw.TextStyle(fontSize: 10)),
                      pw.Row(
                        children: [
                          pw.Text(product.code ?? "--", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(width: 4),
                          pw.Text(product.brandName, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(width: 4),
                          pw.Text(product.unitName, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    item.currentStock.toString(),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.averageCost),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.total),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
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
            padding: const pw.EdgeInsets.all(4),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text("Total en Inventario:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(total),
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
