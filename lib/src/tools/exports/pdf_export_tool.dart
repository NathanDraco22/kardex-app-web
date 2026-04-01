import 'package:kardex_app_front/src/tools/exports/pdf/pdf_template.dart';
import 'package:printing/printing.dart';

class PdfExportTool {
  static Future<void> export(
    PdfTemplate template, {
    String fileName = "documento.pdf",
  }) async {
    final doc = await template.buildDocument();
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: fileName,
    );
  }
}
