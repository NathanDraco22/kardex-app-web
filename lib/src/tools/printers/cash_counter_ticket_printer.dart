import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/widgets/cash_counter/cash_counter_models.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<bool> printCashCounterTicket(
  CashCountRecord record,
  BranchInDb branch, {
  String? userName,
  double? expectedCash,
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromCashCount(
    record,
    branch,
    userName: userName,
    expectedCash: expectedCash,
    paperSize: paperSize,
  );
  return await Printing.layoutPdf(
    onLayout: (_) => bytes,
    name: 'arqueo_ticket_${DateFormat('yyyyMMdd').format(record.date)}.pdf',
  );
}

Future<bool> shareCashCounterTicket(
  CashCountRecord record,
  BranchInDb branch, {
  String? userName,
  double? expectedCash,
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final bytes = await generateTicketPdfFromCashCount(
    record,
    branch,
    userName: userName,
    expectedCash: expectedCash,
    paperSize: paperSize,
  );
  return await Printing.sharePdf(
    bytes: bytes,
    filename: 'arqueo_ticket_${DateFormat('yyyyMMdd').format(record.date)}.pdf',
  );
}

Future<Uint8List> generateTicketPdfFromCashCount(
  CashCountRecord record,
  BranchInDb branch, {
  String? userName,
  double? expectedCash,
  PaperSize paperSize = PaperSize.mm80,
}) async {
  final pdf = pw.Document();

  final pageFormat = PdfPageFormat(
    TicketSettings.ticketWidth(paperSize) * PdfPageFormat.mm,
    double.infinity,
    marginAll: TicketSettings.ticketMargin(paperSize) * PdfPageFormat.mm,
  );

  final f = NumberFormat('#,##0.00', 'en_US');
  final rateF = NumberFormat('#,##0.##', 'en_US');
  final dateF = DateFormat('dd/MM/yyyy');
  final timeF = DateFormat('hh:mm a');

  final branchImage = branch.image;
  final logoSize = TicketSettings.logoSize(paperSize);

  final contentFontSize = TicketSettings.contentFontSize(paperSize);
  final titleFontSize = TicketSettings.titleFontSize(paperSize);

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
          font: await TicketSettings.ticketFont(paperSize),
          fontBold: await TicketSettings.ticketFontBold(paperSize),
        ),
      ),
      build: (pw.Context context) {
        final expected = expectedCash;
        final diff = expected != null ? (record.grandTotalCordobas - expected) : null;

        // Filtrar denominaciones con cantidad mayor a 0
        final activeCordobas = CashDenominations.cordobas.where((d) => record.getCordobaCount(d.value) > 0).toList();
        final activeDollars = CashDenominations.dollars.where((d) => record.getDollarCount(d.value) > 0).toList();

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Logo si existe
            if (branchImage != null && branchImage.isNotEmpty)
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Image(
                  pw.MemoryImage(branchImage),
                  width: logoSize * 0.7,
                  height: logoSize * 0.7,
                ),
              ),
            pw.SizedBox(height: 3),

            // Encabezado Sucursal
            pw.Text(
              branch.name.toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: titleFontSize + 1),
              textAlign: pw.TextAlign.center,
            ),
            if (branch.address.isNotEmpty)
              pw.Text(
                branch.address,
                style: pw.TextStyle(fontSize: contentFontSize - 1),
                textAlign: pw.TextAlign.center,
              ),
            if (branch.phone.isNotEmpty)
              pw.Text(
                "Tel: ${branch.phone}",
                style: pw.TextStyle(fontSize: contentFontSize - 1),
                textAlign: pw.TextAlign.center,
              ),

            pw.SizedBox(height: 5),
            pw.Text(
              "================================",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),
            pw.Text(
              "ARQUEO DE EFECTIVO",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: titleFontSize),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              "CONTEO FÍSICO DE CAJA",
              style: pw.TextStyle(fontSize: contentFontSize - 1),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              "================================",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),

            // Metadatos
            pw.SizedBox(height: 3),
            _buildTicketKeyValue("Fecha:", "${dateF.format(record.date)} ${timeF.format(record.updatedAt)}", contentFontSize),
            _buildTicketKeyValue("Cajero:", userName ?? "Usuario", contentFontSize),
            _buildTicketKeyValue("Sucursal:", branch.name, contentFontSize),

            pw.SizedBox(height: 4),
            pw.Text(
              "--------------------------------",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),

            // Sección Córdobas
            pw.Text(
              "CÓRDOBAS (C\$)",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: contentFontSize),
            ),
            pw.SizedBox(height: 2),
            if (activeCordobas.isEmpty)
              pw.Text(" (Sin billetes contados)", style: pw.TextStyle(fontSize: contentFontSize - 1, color: PdfColors.grey700))
            else
              for (final den in activeCordobas) ...[
                _buildDenominationLine(
                  den.label,
                  record.getCordobaCount(den.value),
                  "C\$ ${f.format(den.value * record.getCordobaCount(den.value))}",
                  contentFontSize,
                ),
              ],
            pw.SizedBox(height: 2),
            _buildTicketKeyValue("Subtotal C\$:", "C\$ ${f.format(record.totalCordobas)} (${record.totalCordobaPieces} pzs)", contentFontSize, isBold: true),

            pw.SizedBox(height: 4),
            pw.Text(
              "--------------------------------",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),

            // Sección Dólares
            pw.Text(
              "DÓLARES (\$)",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: contentFontSize),
            ),
            pw.SizedBox(height: 2),
            if (activeDollars.isEmpty)
              pw.Text(" (Sin dólares contados)", style: pw.TextStyle(fontSize: contentFontSize - 1, color: PdfColors.grey700))
            else
              for (final den in activeDollars) ...[
                _buildDenominationLine(
                  den.label,
                  record.getDollarCount(den.value),
                  "\$ ${f.format(den.value * record.getDollarCount(den.value))}",
                  contentFontSize,
                ),
              ],
            pw.SizedBox(height: 2),
            _buildTicketKeyValue("Subtotal USD:", "\$ ${f.format(record.totalDollars)} (${record.totalDollarPieces} pzs)", contentFontSize, isBold: true),
            _buildTicketKeyValue("Tasa de Cambio:", "1 USD = C\$ ${rateF.format(record.exchangeRate)}", contentFontSize - 1),
            _buildTicketKeyValue("Equiv. en C\$:", "C\$ ${f.format(record.totalDollarsInCordobas)}", contentFontSize),

            pw.SizedBox(height: 5),
            pw.Text(
              "================================",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),

            // Gran Total Físico
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "GRAN TOTAL:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: titleFontSize + 1),
                ),
                pw.Text(
                  "C\$ ${f.format(record.grandTotalCordobas)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: titleFontSize + 2),
                ),
              ],
            ),

            // Comparativa de Sistema
            if (expected != null && diff != null) ...[
              pw.SizedBox(height: 4),
              _buildTicketKeyValue("Efectivo Sistema:", "C\$ ${f.format(expected)}", contentFontSize),
              _buildTicketKeyValue(
                "Diferencia:",
                diff.abs() < 0.01
                    ? "C\$ 0.00 (CUADRADO)"
                    : (diff > 0 ? "+ C\$ ${f.format(diff)} (SOBRANTE)" : "- C\$ ${f.format(diff.abs())} (FALTANTE)"),
                contentFontSize,
                isBold: true,
              ),
            ],

            pw.SizedBox(height: 6),
            pw.Text(
              "--------------------------------",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentFontSize - 2),
            ),
            pw.SizedBox(height: 20),

            // Firmas breves
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 65, height: 0.5, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text("Firma Cajero", style: pw.TextStyle(fontSize: contentFontSize - 2)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 65, height: 0.5, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text("Firma Supervisor", style: pw.TextStyle(fontSize: contentFontSize - 2)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildTicketKeyValue(String key, String value, double fontSize, {bool isBold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(key, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    ),
  );
}

pw.Widget _buildDenominationLine(String label, int qty, String subtotal, double fontSize) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 0.8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text("${label.padRight(8)} x ${qty.toString().padLeft(3)}", style: pw.TextStyle(fontSize: fontSize - 0.5)),
        pw.Text(subtotal, style: pw.TextStyle(fontSize: fontSize - 0.5, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}
