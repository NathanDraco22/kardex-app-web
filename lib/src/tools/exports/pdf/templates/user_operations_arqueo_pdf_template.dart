import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:kardex_app_front/widgets/pdf/basic_pdf_table_listview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class UserOperationsArqueoPdfTemplate implements PdfTemplate {
  final TotalsResult result;
  final BranchInDb branch;
  final UserInDb? user;
  final DateTime? date;

  UserOperationsArqueoPdfTemplate({
    required this.result,
    required this.branch,
    this.user,
    this.date,
  });

  @override
  Future<pw.Document> buildDocument() async {
    final doc = pw.Document();

    final validInvoices = result.detailInvoices.where((e) => e.paymentType != PaymentType.credit).toList();
    final creditInvoices = result.detailInvoices.where((e) => e.paymentType == PaymentType.credit).toList();
    final validReceipts = result.detailReceipts;

    final invoicesTotal = validInvoices.fold<int>(0, (prev, e) => prev + e.total);
    final creditInvoicesTotal = creditInvoices.fold<int>(0, (prev, e) => prev + e.total);
    final receiptsTotal = validReceipts.fold<int>(0, (prev, e) => prev + e.total);
    final grandTotal = invoicesTotal + receiptsTotal;

    // Resumen de flujo por tipo
    final cardInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.card);
    final cardReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.card);
    final totalTarjetas =
        cardInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        cardReceipts.fold<int>(0, (prev, rec) => prev + rec.total);

    final transferInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.transfer);
    final transferReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.transfer);
    final totalTransferencias =
        transferInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        transferReceipts.fold<int>(0, (prev, rec) => prev + rec.total);

    final cashInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.cash);
    final totalFacturasEfectivo = cashInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    final cashReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.cash);
    final totalAbonosEfectivo = cashReceipts.fold<int>(0, (prev, rec) => prev + rec.total);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 14),
            _buildSummaryInfo(
              invoicesTotal: invoicesTotal,
              receiptsTotal: receiptsTotal,
              grandTotal: grandTotal,
              totalEfectivo: totalFacturasEfectivo + totalAbonosEfectivo,
              totalTarjetas: totalTarjetas,
              totalTransferencias: totalTransferencias,
              totalCreditos: creditInvoicesTotal,
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              "Detalle de Recibos y Abonos",
              style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            ),
            pw.SizedBox(height: 6),
            _buildReceiptsTable(validReceipts),
            pw.SizedBox(height: 18),
            pw.Text(
              "Detalle de Facturas de Contado",
              style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),
            _buildInvoicesTable(validInvoices),
            if (creditInvoices.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Ventas al Crédito (${creditInvoices.length})",
                    style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                  ),
                  pw.Text(
                    "Total Créditos: ${NumberFormatter.convertToMoneyLike(creditInvoicesTotal)}",
                    style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              _buildCreditInvoicesTable(creditInvoices),
            ],
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
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                    if (branch.phone.isNotEmpty || branch.email.isNotEmpty)
                      pw.Text(
                        "Tel: ${branch.phone} | Email: ${branch.email}",
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
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
              "ARQUEO DE CAJA / TURNO",
              style: const pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal800,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              "Emisión: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummaryInfo({
    required int invoicesTotal,
    required int receiptsTotal,
    required int grandTotal,
    required int totalEfectivo,
    required int totalTarjetas,
    required int totalTransferencias,
    required int totalCreditos,
  }) {
    final dateStr = date != null ? DateTimeTool.formatddMMyyEs(date!) : DateTimeTool.formatddMMyyEs(DateTime.now());
    final userName = user != null ? user!.username : "Todos los Usuarios";

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Usuario / Cajero: $userName",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Fecha de Operaciones: $dateStr",
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "TOTAL ARQUEO: ${NumberFormatter.convertToMoneyLike(grandTotal)}",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.teal900),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Efectivo en Caja: ${NumberFormatter.convertToMoneyLike(totalEfectivo)}",
                    style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Facturas Contado: ${NumberFormatter.convertToMoneyLike(invoicesTotal)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "Recibos / Abonos: ${NumberFormatter.convertToMoneyLike(receiptsTotal)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "Tarjetas: ${NumberFormatter.convertToMoneyLike(totalTarjetas)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Transferencias: ${NumberFormatter.convertToMoneyLike(totalTransferencias)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "Créditos Emitidos: ${NumberFormatter.convertToMoneyLike(totalCreditos)}",
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
              ),
              pw.SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReceiptsTable(List<ReceiptInDb> receipts) {
    if (receipts.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          "No hay recibos registrados en este período.",
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
    }

    return BasicPdfTableListView(
      itemCount: receipts.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Hora", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 1,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Recibo #", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cliente", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 4,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Método", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text(
            "Total",
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final r = receipts[index];
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey100;
        final timeStr = DateTimeTool.formatHHmm(r.createdAt);

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(timeStr, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text("#${r.docNumber}", style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(r.clientInfo.name, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(r.paymentMethod.display, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(
              content: pw.Text(
                NumberFormatter.convertToMoneyLike(r.total),
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildInvoicesTable(List<InvoiceInDb> invoices) {
    if (invoices.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          "No hay facturas de contado registradas en este período.",
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
    }

    return BasicPdfTableListView(
      itemCount: invoices.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Hora", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 1,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Factura #", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cliente", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 4,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Tipo Pago", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text(
            "Total",
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final inv = invoices[index];
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey100;
        final timeStr = DateTimeTool.formatHHmm(inv.createdAt);

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(timeStr, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text("#${inv.docNumber}", style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(inv.clientInfo.name, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(inv.paymentType.typeLabel, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(
              content: pw.Text(
                NumberFormatter.convertToMoneyLike(inv.total),
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildCreditInvoicesTable(List<InvoiceInDb> invoices) {
    return BasicPdfTableListView(
      itemCount: invoices.length,
      columns: [
        BasicPdfTableColumn(
          label: pw.Text("Hora", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 1,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Factura #", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Cliente", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 4,
        ),
        BasicPdfTableColumn(
          label: pw.Text("Condición", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          flex: 2,
        ),
        BasicPdfTableColumn(
          label: pw.Text(
            "Total Crédito",
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
          flex: 2,
        ),
      ],
      rowBuilder: (context, index) {
        final inv = invoices[index];
        final rowColor = index.isOdd ? PdfColors.white : PdfColors.grey100;
        final timeStr = DateTimeTool.formatHHmm(inv.createdAt);

        return BasicPdfTableRow(
          color: rowColor,
          cells: [
            BasicPdfTableCell(content: pw.Text(timeStr, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text("#${inv.docNumber}", style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(inv.clientInfo.name, style: const pw.TextStyle(fontSize: 9))),
            BasicPdfTableCell(content: pw.Text(inv.paymentType.typeLabel, style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange900))),
            BasicPdfTableCell(
              content: pw.Text(
                NumberFormatter.convertToMoneyLike(inv.total),
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }
}
