import 'dart:typed_data';

import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Plantilla PDF A4 multipágina para el Estado de Cuenta de Facturas Pendientes.
class PendingInvoicesStatementPdfTemplate implements PdfTemplate {
  final ClientInDb client;
  final BranchInDb? branch;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final String badgeText;
  final String tableTitle;

  PendingInvoicesStatementPdfTemplate({
    required this.client,
    required this.branch,
    required this.invoices,
    required this.devolutions,
    required this.creditNotes,
    this.badgeText = 'ESTADO DE CUENTA',
    this.tableTitle = 'DETALLE DE FACTURAS PENDIENTES',
  });

  @override
  Future<pw.Document> buildDocument() async {
    final logoBytes = await branch?.resolveLogoBytes();
    final doc = await PdfTheme.newDocument();
    final generatedAt = DateTime.now();

    final totalInvoices = invoices.fold(0, (sum, inv) => sum + inv.totalRemaining);
    final totalDevolutions = devolutions.fold(0, (sum, d) => sum + d.total);
    final totalCreditNotes = creditNotes.fold(0, (sum, cn) => sum + cn.total);
    final netTotal = (totalInvoices - totalDevolutions - totalCreditNotes) > 0
        ? (totalInvoices - totalDevolutions - totalCreditNotes)
        : 0;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildHeader(logoBytes, generatedAt),
          pw.SizedBox(height: 14),
          pw.Divider(height: 1, thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 14),
          _buildClientCard(),
          pw.SizedBox(height: 18),
          pw.Text(
            '$tableTitle (${invoices.length})',
            style: const pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInvoicesTable(),
          if (creditNotes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildCreditNotesBanner(totalCreditNotes),
          ],
          pw.SizedBox(height: 16),
          _buildTotalsBox(
            totalInvoices: totalInvoices,
            totalDevolutions: totalDevolutions,
            totalCreditNotes: totalCreditNotes,
            netTotal: netTotal,
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader(Uint8List? logoBytes, DateTime generatedAt) {
    final branchInfo = branch;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoBytes != null && logoBytes.isNotEmpty) ...[
                pw.Container(
                  width: 54,
                  height: 54,
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      branchInfo?.name ?? 'KARDEX APP',
                      style: const pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    if (branchInfo?.formattedRuc != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        branchInfo!.formattedRuc!,
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                    if (branchInfo != null && branchInfo.address.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        branchInfo.address,
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                    if (branchInfo != null && branchInfo.phone.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Tel: ${branchInfo.phone}',
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColors.indigo50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: PdfColors.indigo200),
              ),
              child: pw.Text(
                badgeText,
                style: const pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo800,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Fecha: ${DateTimeTool.formatddMMyyEs(generatedAt)} ${DateTimeTool.formatHHmm(generatedAt)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildClientCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CLIENTE',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  client.name,
                  style: const pw.TextStyle(
                    fontSize: 12.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                if (client.cardId != null && client.cardId!.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'ID / Cédula: ${client.cardId}',
                    style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CONTACTO Y DIRECCIÓN',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                if (client.phone != null && client.phone!.isNotEmpty)
                  pw.Text(
                    'Tel: ${client.phone}',
                    style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                  ),
                if (client.location != null && client.location!.isNotEmpty)
                  pw.Text(
                    client.location!,
                    style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoicesTable() {
    final headers = [
      'Factura',
      'Fecha',
      'Total Factura',
      'Abonos',
      'A Favor (NC/Dev)',
      'Saldo Pendiente',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.4),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FlexColumnWidth(1.6),
        4: pw.FlexColumnWidth(1.9),
        5: pw.FlexColumnWidth(1.9),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
          repeat: true,
          children: List.generate(headers.length, (index) {
            final isRight = index >= 2;
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: pw.Text(
                headers[index],
                textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
                style: const pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
            );
          }),
        ),
        ...List.generate(invoices.length, (index) {
          final inv = invoices[index];
          final targetDev = devolutions.where((d) => d.originalInvoiceId == inv.id);
          final targetCn = creditNotes.where(
            (cn) => cn.invoiceId == inv.id || (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == inv.docNumber),
          );

          final devTotal = targetDev.fold(0, (sum, d) => sum + d.total);
          final cnTotal = targetCn.fold(0, (sum, c) => sum + c.total);
          final discounts = devTotal + cnTotal;
          final remaining = inv.totalRemaining - discounts;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isOdd ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              _tableCell('#${inv.docNumber}', bold: true),
              _tableCell(DateTimeTool.formatddMMyyEs(inv.createdAt)),
              _tableCell(NumberFormatter.convertToMoneyLike(inv.total), alignRight: true),
              _tableCell(
                NumberFormatter.convertToMoneyLike(inv.amountPaid),
                alignRight: true,
                color: PdfColors.teal700,
              ),
              _tableCell(
                discounts > 0 ? '-${NumberFormatter.convertToMoneyLike(discounts)}' : '0.00',
                alignRight: true,
                color: discounts > 0 ? PdfColors.purple700 : PdfColors.grey600,
              ),
              _tableCell(
                NumberFormatter.convertToMoneyLike(remaining),
                alignRight: true,
                bold: true,
                color: PdfColors.indigo800,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableCell(
    String text, {
    bool alignRight = false,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.blueGrey900,
        ),
      ),
    );
  }

  pw.Widget _buildCreditNotesBanner(int totalCreditNotes) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: PdfColors.purple200),
      ),
      child: pw.Text(
        'El cliente cuenta con ${creditNotes.length} Nota(s) de Crédito a favor por un total de ${NumberFormatter.convertToMoneyLike(totalCreditNotes)}.',
        style: const pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.purple800,
        ),
      ),
    );
  }

  pw.Widget _buildTotalsBox({
    required int totalInvoices,
    required int totalDevolutions,
    required int totalCreditNotes,
    required int netTotal,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 240,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            children: [
              _buildTotalRow('Subtotal Facturas:', NumberFormatter.convertToMoneyLike(totalInvoices)),
              if (totalDevolutions > 0)
                _buildTotalRow(
                  'Total Devoluciones:',
                  '-${NumberFormatter.convertToMoneyLike(totalDevolutions)}',
                  color: PdfColors.orange800,
                ),
              if (totalCreditNotes > 0)
                _buildTotalRow(
                  'Notas de Crédito a Favor:',
                  '-${NumberFormatter.convertToMoneyLike(totalCreditNotes)}',
                  color: PdfColors.purple700,
                ),
              pw.Divider(height: 12, thickness: 0.8, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'NETO A PAGAR:',
                    style: const pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Text(
                    NumberFormatter.convertToMoneyLike(netTotal),
                    style: const pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: color ?? PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Divider(height: 1, thickness: 0.6, color: PdfColors.grey300),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Kardex App • Comprobante Informativo de Cuentas por Cobrar',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
