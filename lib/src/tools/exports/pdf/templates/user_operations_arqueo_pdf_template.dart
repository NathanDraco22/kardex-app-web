import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
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
    await branch.resolveLogoBytes();
    final doc = await PdfTheme.newDocument();

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

    final cardByBank = groupReferencesByBank([
      ...cardInvoices.map((inv) => (bankReference: inv.bankReference, amount: inv.total)),
      ...cardReceipts.map((rec) => (bankReference: rec.bankReference, amount: rec.total)),
    ]);
    final transferByBank = groupReferencesByBank([
      ...transferInvoices.map((inv) => (bankReference: inv.bankReference, amount: inv.total)),
      ...transferReceipts.map((rec) => (bankReference: rec.bankReference, amount: rec.total)),
    ]);

    final dateStr = date != null ? DateTimeTool.formatddMMyyEs(date!) : DateTimeTool.formatddMMyyEs(DateTime.now());
    final userName = user != null ? user!.username : "Todos los Usuarios";

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 32),
        footer: (context) => _buildFooter(context, dateStr),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 12),
            _buildSummaryInfo(
              userName: userName,
              dateStr: dateStr,
              invoicesTotal: invoicesTotal,
              receiptsTotal: receiptsTotal,
              grandTotal: grandTotal,
              totalEfectivo: totalFacturasEfectivo + totalAbonosEfectivo,
              totalTarjetas: totalTarjetas,
              totalTransferencias: totalTransferencias,
              totalCreditos: creditInvoicesTotal,
              cardByBank: cardByBank,
              transferByBank: transferByBank,
            ),
            pw.SizedBox(height: 18),
            _sectionTitle("Detalle de Recibos y Abonos (${validReceipts.length})"),
            _buildReceiptsTable(validReceipts),
            pw.SizedBox(height: 18),
            _sectionTitle("Detalle de Facturas de Contado (${validInvoices.length})"),
            _buildInvoicesTable(validInvoices),
            if (creditInvoices.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _sectionTitle(
                "Ventas al Crédito (${creditInvoices.length})",
                trailing: "Total Créditos: ${NumberFormatter.convertToMoneyLike(creditInvoicesTotal)}",
              ),
              _buildCreditInvoicesTable(creditInvoices),
            ],
            pw.SizedBox(height: 28),
            _buildSignaturesBlock(userName),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader() {
    final branchImage = branch.image;

    return pw.Column(
      children: [
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
                      width: 48,
                      height: 48,
                      fit: pw.BoxFit.contain,
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          branch.name,
                          style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        if (branch.address.isNotEmpty)
                          pw.Text(
                            branch.address,
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                          ),
                        if (branch.phone.isNotEmpty || branch.email.isNotEmpty)
                          pw.Text(
                            [
                              if (branch.phone.isNotEmpty) "Tel: ${branch.phone}",
                              if (branch.email.isNotEmpty) branch.email,
                            ].join("  |  "),
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
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
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.black, width: 1.2),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    "ARQUEO DE CAJA / TURNO",
                    style: const pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "Emisión: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1.5, color: PdfColors.black),
      ],
    );
  }

  pw.Widget _buildSummaryInfo({
    required String userName,
    required String dateStr,
    required int invoicesTotal,
    required int receiptsTotal,
    required int grandTotal,
    required int totalEfectivo,
    required int totalTarjetas,
    required int totalTransferencias,
    required int totalCreditos,
    required List<BankBreakdownEntry> cardByBank,
    required List<BankBreakdownEntry> transferByBank,
  }) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Usuario / Cajero: $userName",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Fecha de Operaciones: $dateStr",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "TOTAL ARQUEO: ${NumberFormatter.convertToMoneyLike(grandTotal)}",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Efectivo en Caja: ${NumberFormatter.convertToMoneyLike(totalEfectivo)}",
                    style: const pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Facturas Contado: ${NumberFormatter.convertToMoneyLike(invoicesTotal)}",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                  ),
                  pw.Text(
                    "Recibos / Abonos: ${NumberFormatter.convertToMoneyLike(receiptsTotal)}",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                  ),
                  pw.Text(
                    "Tarjetas: ${NumberFormatter.convertToMoneyLike(totalTarjetas)}",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Transferencias: ${NumberFormatter.convertToMoneyLike(totalTransferencias)}",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                  ),
                  pw.Text(
                    "Créditos Emitidos: ${NumberFormatter.convertToMoneyLike(totalCreditos)}",
                    style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                  ),
                  pw.SizedBox(width: 80),
                ],
              ),
              if (transferByBank.isNotEmpty || cardByBank.isNotEmpty) ...[
                pw.Divider(color: PdfColors.grey300, height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (transferByBank.isNotEmpty)
                      pw.Expanded(
                        child: _buildBankBreakdownPdfColumn(
                          'Transferencias por Banco',
                          transferByBank,
                        ),
                      ),
                    if (transferByBank.isNotEmpty && cardByBank.isNotEmpty)
                      pw.SizedBox(width: 16),
                    if (cardByBank.isNotEmpty)
                      pw.Expanded(
                        child: _buildBankBreakdownPdfColumn(
                          'Tarjetas por Banco',
                          cardByBank,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _sectionTitle(String title, {String? trailing}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 4),
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.0),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: const pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          if (trailing != null)
            pw.Text(
              trailing,
              style: const pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildBankBreakdownPdfColumn(
    String title,
    List<BankBreakdownEntry> entries,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 3),
        ...entries.map(
          (e) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '• ${e.bankName} (${e.count})',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
              pw.Text(
                NumberFormatter.convertToMoneyLike(e.totalCents),
                style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
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
            BasicPdfTableCell(
              content: pw.Text(
                r.bankReference.trim().isNotEmpty
                    ? '${r.paymentMethod.display} (${r.bankReference.trim()})'
                    : r.paymentMethod.display,
                style: const pw.TextStyle(fontSize: 8.5),
              ),
            ),
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
            BasicPdfTableCell(
              content: pw.Text(
                inv.bankReference.trim().isNotEmpty
                    ? '${inv.paymentType.typeLabel} (${inv.bankReference.trim()})'
                    : inv.paymentType.typeLabel,
                style: const pw.TextStyle(fontSize: 8.5),
              ),
            ),
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
            BasicPdfTableCell(
              content: pw.Text(
                inv.paymentType.typeLabel,
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
              ),
            ),
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

  pw.Widget _buildSignaturesBlock(String userName) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _signatureColumn('Cajero / Responsable', userName),
        pw.SizedBox(width: 40),
        _signatureColumn('Supervisor / Recibido por', ''),
      ],
    );
  }

  pw.Widget _signatureColumn(String role, String name) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Container(height: 1, color: PdfColors.black),
          pw.SizedBox(height: 4),
          pw.Text(
            role,
            style: const pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          if (name.isNotEmpty)
            pw.Text(
              name,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "${branch.name}  •  Arqueo de Operaciones ($dateStr)",
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
          pw.Text(
            "Página ${context.pageNumber} de ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
