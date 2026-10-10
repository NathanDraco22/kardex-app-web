import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/cash_counter/cash_counter_models.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CashCounterPdfTemplate implements PdfTemplate {
  final CashCountRecord record;
  final BranchInDb branch;
  final String? userName;
  final DateTime date;
  final double? expectedCash;

  CashCounterPdfTemplate({
    required this.record,
    required this.branch,
    this.userName,
    required this.date,
    this.expectedCash,
  });

  @override
  Future<pw.Document> buildDocument() async {
    final doc = pw.Document();
    final f = NumberFormat('#,##0.00', 'en_US');
    final rateF = NumberFormat('#,##0.##', 'en_US');
    final dateF = DateFormat('dd/MM/yyyy');
    final timeF = DateFormat('hh:mm a');

    final branchImage = branch.image;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabecera institucional
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
                          width: 50,
                          height: 50,
                        ),
                        pw.SizedBox(width: 12),
                      ],
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              branch.name,
                              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              branch.address,
                              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                            ),
                            if (branch.phone.isNotEmpty)
                              pw.Text(
                                "Tel: ${branch.phone}",
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal800,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        "ARQUEO DE EFECTIVO",
                        style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Fecha: ${dateF.format(date)}",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      "Hora: ${timeF.format(record.updatedAt)}",
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      "Cajero: ${userName ?? 'Usuario'}",
                      style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 10),

            // Tablas en 2 columnas: Córdobas a la izquierda, Dólares a la derecha
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Columna Izquierda: Córdobas
                pw.Expanded(
                  flex: 6,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: PdfColors.teal50,
                        child: pw.Row(
                          children: [
                            pw.Text(
                              "CÓRDOBAS (C\$)",
                              style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              "Subtotal: C\$ ${f.format(record.totalCordobas)}",
                              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      _buildCordobasTable(f),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                // Columna Derecha: Dólares y Resumen
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: PdfColors.green50,
                        child: pw.Row(
                          children: [
                            pw.Text(
                              "DÓLARES (\$)",
                              style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              "Subtotal: \$ ${f.format(record.totalDollars)}",
                              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      _buildDollarsTable(f),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            // Resumen Consolidado y Comparativa
            _buildConsolidatedSummary(f, rateF),

            pw.SizedBox(height: 36),
            // Sección de Firmas
            _buildSignatures(),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildCordobasTable(NumberFormat f) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeaderCell("Denominación"),
            _tableHeaderCell("Tipo", align: pw.TextAlign.center),
            _tableHeaderCell("Cant.", align: pw.TextAlign.center),
            _tableHeaderCell("Subtotal C\$", align: pw.TextAlign.right),
          ],
        ),
        for (int i = 0; i < CashDenominations.cordobas.length; i++) ...[
          _buildCordobaRow(CashDenominations.cordobas[i], f, i.isOdd),
        ],
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal50),
          children: [
            _tableTotalCell("TOTAL C\$"),
            _tableTotalCell(""),
            _tableTotalCell("${record.totalCordobaPieces} pzs", align: pw.TextAlign.center),
            _tableTotalCell("C\$ ${f.format(record.totalCordobas)}", align: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildCordobaRow(DenominationConfig den, NumberFormat f, bool isOdd) {
    final qty = record.getCordobaCount(den.value);
    final subtotal = den.value * qty;
    final rowBg = qty > 0 ? (isOdd ? PdfColors.teal50 : PdfColors.white) : (isOdd ? PdfColors.grey100 : PdfColors.white);

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowBg),
      children: [
        _tableCell(den.label),
        _tableCell(den.typeLabel, align: pw.TextAlign.center),
        _tableCell(qty > 0 ? qty.toString() : "-", align: pw.TextAlign.center, isBold: qty > 0),
        _tableCell(qty > 0 ? "C\$ ${f.format(subtotal)}" : "C\$ 0.00", align: pw.TextAlign.right, isBold: qty > 0),
      ],
    );
  }

  pw.Widget _buildDollarsTable(NumberFormat f) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeaderCell("Denominación"),
            _tableHeaderCell("Cant.", align: pw.TextAlign.center),
            _tableHeaderCell("Subtotal USD", align: pw.TextAlign.right),
          ],
        ),
        for (int i = 0; i < CashDenominations.dollars.length; i++) ...[
          _buildDollarRow(CashDenominations.dollars[i], f, i.isOdd),
        ],
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green50),
          children: [
            _tableTotalCell("TOTAL USD"),
            _tableTotalCell("${record.totalDollarPieces} pzs", align: pw.TextAlign.center),
            _tableTotalCell("\$ ${f.format(record.totalDollars)}", align: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildDollarRow(DenominationConfig den, NumberFormat f, bool isOdd) {
    final qty = record.getDollarCount(den.value);
    final subtotal = den.value * qty;
    final rowBg = qty > 0 ? (isOdd ? PdfColors.green50 : PdfColors.white) : (isOdd ? PdfColors.grey100 : PdfColors.white);

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowBg),
      children: [
        _tableCell(den.label),
        _tableCell(qty > 0 ? qty.toString() : "-", align: pw.TextAlign.center, isBold: qty > 0),
        _tableCell(qty > 0 ? "\$ ${f.format(subtotal)}" : "\$ 0.00", align: pw.TextAlign.right, isBold: qty > 0),
      ],
    );
  }

  pw.Widget _buildConsolidatedSummary(NumberFormat f, NumberFormat rateF) {
    final expected = expectedCash;
    final diff = expected != null ? (record.grandTotalCordobas - expected) : null;

    PdfColor statusColor = PdfColors.grey800;
    String statusText = "Sin referencia de sistema";

    if (diff != null) {
      if (diff.abs() < 0.01) {
        statusColor = PdfColors.green800;
        statusText = "CUADRADO EXACTO (Diferencia C\$ 0.00)";
      } else if (diff > 0) {
        statusColor = PdfColors.blue800;
        statusText = "SOBRANTE DE C\$ ${f.format(diff)}";
      } else {
        statusColor = PdfColors.red800;
        statusText = "FALTANTE DE C\$ ${f.format(diff.abs())}";
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "CONSOLIDADO DE ARQUEO FÍSICO",
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.teal900),
              ),
              pw.Text(
                "Tasa de Cambio: 1 USD = C\$ ${rateF.format(record.exchangeRate)}",
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Subtotal Físico Córdobas: C\$ ${f.format(record.totalCordobas)} (${record.totalCordobaPieces} piezas)", style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 2),
                  pw.Text("Subtotal Físico Dólares: \$ ${f.format(record.totalDollars)} (${record.totalDollarPieces} billetes)", style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 2),
                  pw.Text("Equivalente USD en Córdobas: C\$ ${f.format(record.totalDollarsInCordobas)}", style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("GRAN TOTAL FÍSICO:", style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text("C\$ ${f.format(record.grandTotalCordobas)}", style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                ],
              ),
            ],
          ),
          if (expected != null) ...[
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Efectivo Esperado en Sistema: C\$ ${f.format(expected)}", style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text("Resultado: $statusText", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: statusColor)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
          children: [
            pw.Container(width: 170, height: 1, color: PdfColors.grey600),
            pw.SizedBox(height: 4),
            pw.Text("Firma del Cajero(a)", style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text(userName ?? "Cajero Responsable", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 170, height: 1, color: PdfColors.grey600),
            pw.SizedBox(height: 4),
            pw.Text("Firma del Supervisor(a)", style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text("Administración / Arqueo", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isBold ? PdfColors.black : PdfColors.grey800,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableTotalCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
        textAlign: align,
      ),
    );
  }
}
