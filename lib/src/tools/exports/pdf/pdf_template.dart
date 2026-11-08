import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class PdfTemplate {
  Future<pw.Document> buildDocument();
}

class PdfTheme {
  static pw.Font? _fallback;

  static Future<pw.Document> newDocument() async {
    _fallback ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );

    return pw.Document(
      theme: pw.ThemeData.withFont(fontFallback: [_fallback!]),
    );
  }
}
