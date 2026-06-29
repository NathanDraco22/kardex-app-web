import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SingleAdjustEntryTemplate implements PdfTemplate {
  final AdjustEntryInDb adjustEntry;
  final BranchInDb branch;

  SingleAdjustEntryTemplate({
    required this.adjustEntry,
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
    final createdAtMs = adjustEntry.createdAt;
    final createdDate = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(createdAtMs));
    final createdTime = DateTimeTool.formatHHmm(DateTime.fromMillisecondsSinceEpoch(createdAtMs));

    final total = adjustEntry.items.fold<int>(0, (prev, item) {
      return prev + (item.cost * item.quantity);
    });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          "Entrada por Ajuste",
          style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "No. ${adjustEntry.docNumber}",
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Row(
              children: [
                pw.Text(
                  createdDate,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.Text(" | ", style: const pw.TextStyle(fontSize: 14)),
                pw.Text(
                  createdTime,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Sucursal: ${branch.name}",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                  pw.Text(
                    "Total: ${NumberFormatter.convertToMoneyLike(total)}",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              if (adjustEntry.description.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  "Descripción: ${adjustEntry.description}",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 14),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Text(
                "Elaborado por:",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
              pw.Text(
                adjustEntry.createdBy.name,
                style: const pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 14),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
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
                  "Costo",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  "Subtotal",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(adjustEntry.items.length, (index) {
          final item = adjustEntry.items[index];
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
                      pw.Text(item.productName, style: const pw.TextStyle(fontSize: 10)),
                      pw.Row(
                        children: [
                          pw.Text(item.code ?? "", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(width: 4),
                          pw.Text(item.brandName ?? "", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(width: 4),
                          pw.Text(item.unitName ?? "", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    item.quantity.toString(),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.cost),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.cost * item.quantity),
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
    final total = adjustEntry.items.fold<int>(0, (prev, item) {
      return prev + (item.cost * item.quantity);
    });

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
                pw.Text("Total:", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(
                  width: 110,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(total),
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
