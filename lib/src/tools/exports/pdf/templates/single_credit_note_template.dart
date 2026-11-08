import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SingleCreditNoteTemplate implements PdfTemplate {
  final CreditNoteInDb creditNote;
  final BranchInDb branch;

  SingleCreditNoteTemplate({
    required this.creditNote,
    required this.branch,
  });

  @override
  Future<pw.Document> buildDocument() async {
    await branch.resolveLogoBytes();
    final doc = await PdfTheme.newDocument();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.Divider(color: PdfColors.grey400),
            if (creditNote.type == CreditNoteType.devolution && creditNote.returnedItems.isNotEmpty) ...[
              _buildTableSection(),
              pw.Divider(color: PdfColors.grey400),
            ] else ...[
              _buildAmountDetailsSection(),
              pw.Divider(color: PdfColors.grey400),
            ],
            _buildTotals(),
          ];
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildHeader() {
    final branchImage = branch.image;
    final isDevolution = creditNote.type == CreditNoteType.devolution;
    String clientLabel = "${creditNote.clientId} - ${creditNote.clientInfo.name}";
    if (creditNote.clientId == "SALE_CLIENT") {
      clientLabel = creditNote.clientInfo.name;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                      width: 60,
                      height: 60,
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          branch.name,
                          style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          branch.address,
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Tel: ${branch.phone} | Email: ${branch.email}",
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
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
                  "NOTA DE CRÉDITO",
                  style: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "No. ${creditNote.docNumber}",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  "Modalidad: ${creditNote.type.display}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: isDevolution ? PdfColors.indigo900 : PdfColors.teal900,
                  ),
                ),
                if (isDevolution && creditNote.originalInvoiceDocNumber.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Factura Origen: #${creditNote.originalInvoiceDocNumber}",
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                ],
                pw.SizedBox(height: 2),
                pw.Text(
                  "${DateTimeTool.formatddMMyy(creditNote.createdAt)} ${DateTimeTool.formatHHmm(creditNote.createdAt)}",
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
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
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "CLIENTE",
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      clientLabel,
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                    if (creditNote.clientInfo.location != null && creditNote.clientInfo.location!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${creditNote.clientInfo.location}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    if (creditNote.clientInfo.address != null && creditNote.clientInfo.address!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "${creditNote.clientInfo.address}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Elaborado por: ${creditNote.createdBy.name}",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "ESTADO Y APLICACIÓN",
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Estado: ${creditNote.status.display.toUpperCase()}",
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    if (creditNote.appliedReceiptDocNumber != null &&
                        creditNote.appliedReceiptDocNumber!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Aplicada en Recibo: #${creditNote.appliedReceiptDocNumber}",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.indigo800),
                      ),
                    ],
                    if (creditNote.description.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Motivo: ${creditNote.description}",
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAmountDetailsSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "CONCEPTO DEL CRÉDITO:",
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey200),
            ),
            child: pw.Text(
              creditNote.description.isNotEmpty
                  ? creditNote.description
                  : "Crédito financiero o ajuste concedido a la cuenta del cliente.",
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
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
                child: pw.Text(
                  "Producto Devuelto",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
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
                  "Precio",
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
        ...List.generate(creditNote.returnedItems.length, (index) {
          final item = creditNote.returnedItems[index];
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
                      pw.Text(item.product.name, style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        item.product.unitName,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    item.formattedDisplayQuantity,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.price * item.conversionFactor),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(item.subTotal),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 12),
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
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  "Total Saldo a Favor:",
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    NumberFormatter.convertToMoneyLike(creditNote.amount),
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 15,
                      color: PdfColors.indigo900,
                    ),
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
