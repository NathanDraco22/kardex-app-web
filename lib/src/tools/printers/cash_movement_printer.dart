import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:pdf/widgets.dart' as pw;

/// Imprime el comprobante térmico de un movimiento de caja en turno.
Future<bool> printCashMovementTicket(
  ShiftCashMovementInDb movement,
  BranchInDb branch, {
  String? shiftDocNumber,
  PaperSize? paperSize,
}) async {
  final effectivePaperSize = paperSize ?? await PrintManager.getLocalPaperSize();
  final bytes = await generateCashMovementTicketPdf(
    movement,
    branch,
    shiftDocNumber: shiftDocNumber,
    paperSize: effectivePaperSize,
  );
  final docLabel = movement.docNumber.isNotEmpty ? movement.docNumber : movement.id;
  return PrintManager.printPdf(
    bytes,
    name: 'movimiento_caja_$docLabel.pdf',
    paperSize: effectivePaperSize,
  );
}

/// Genera el PDF en formato ticket térmico para un movimiento de caja en turno.
Future<Uint8List> generateCashMovementTicketPdf(
  ShiftCashMovementInDb movement,
  BranchInDb branch, {
  String? shiftDocNumber,
  PaperSize paperSize = PaperSize.mm80,
  double? extraRightMarginMm,
}) async {
  final pdf = pw.Document();
  final pageFormat = await PrintManager.getTicketPageFormat(
    paperSize,
    extraRightMarginMm: extraRightMarginMm,
  );

  final branchImage = await branch.resolveLogoBytes();
  final logoSize = TicketSettings.logoSize(paperSize);
  final contentSize = TicketSettings.contentFontSize(paperSize);
  final titleSize = TicketSettings.titleFontSize(paperSize);
  final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

  final isIn = movement.type == CashMovementType.inMovement;
  final typeTitle = isIn ? 'ENTRADA DE CAJA' : 'SALIDA DE CAJA';
  final sign = isIn ? '+' : '-';
  final shiftLabel = (shiftDocNumber != null && shiftDocNumber.isNotEmpty)
      ? '#$shiftDocNumber'
      : movement.shiftId;

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (branchImage != null && branchImage.isNotEmpty)
            pw.Center(
              child: pw.Image(
                pw.MemoryImage(branchImage),
                height: logoSize,
                fit: pw.BoxFit.contain,
              ),
            ),
          pw.SizedBox(height: 6),
          pw.Text(
            branch.name.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: titleSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (branch.formattedRuc != null)
            pw.Text(
              branch.formattedRuc!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: contentSize),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'MOVIMIENTO DE CAJA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: contentSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            movement.docNumber.isNotEmpty
                ? '$typeTitle #${movement.docNumber}'
                : typeTitle,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: contentSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Turno:',
                style: pw.TextStyle(
                  fontSize: contentSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                shiftLabel,
                style: pw.TextStyle(fontSize: contentSize),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Fecha y hora:',
                style: pw.TextStyle(
                  fontSize: contentSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                dateFormat.format(movement.createdAt),
                style: pw.TextStyle(fontSize: contentSize),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Usuario:',
                style: pw.TextStyle(
                  fontSize: contentSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Flexible(
                child: pw.Text(
                  movement.createdBy.name,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: contentSize),
                ),
              ),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'MONTO:',
                style: pw.TextStyle(
                  fontSize: titleSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '$sign${NumberFormatter.convertToMoneyLike(movement.amount)}',
                style: pw.TextStyle(
                  fontSize: titleSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(),
          pw.Text(
            'Justificación:',
            style: pw.TextStyle(
              fontSize: contentSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            movement.reason.isNotEmpty ? movement.reason : 'Sin justificación',
            style: pw.TextStyle(fontSize: contentSize),
          ),
          if (movement.registerAsExpense) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Registrado como gasto: ${movement.expenseCategory ?? 'General'}',
              style: pw.TextStyle(fontSize: contentSize),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Firma de recibido / responsable',
              style: pw.TextStyle(fontSize: contentSize - 1),
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    ),
  );

  return pdf.save();
}
