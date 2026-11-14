import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketSettings {
  static pw.Font? _font;
  static pw.Font? _fontBold;
  static pw.Font? _fallbackFont;
  static double titleFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 9.0;
  static double contentFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 9.0;
  static double ticketWidth(PaperSize size) => size == PaperSize.mm58 ? 50.0 : 72.0;
  static double ticketMargin(PaperSize size) => size == PaperSize.mm58 ? 1.0 : 2.0;
  static double ticketMarginLeft(PaperSize size) => size == PaperSize.mm58 ? 1.0 : 2.0;
  static double ticketMarginRight(
    PaperSize size, {
    double extraRightMarginMm = 0.0,
  }) {
    if (size == PaperSize.mm58) return 1.0;
    final clampedExtra = extraRightMarginMm.clamp(0.0, 15.0).toDouble();
    return 5.0 + clampedExtra;
  }

  static double ticketMarginVertical(PaperSize size) => size == PaperSize.mm58 ? 1.0 : 2.0;

  static PdfPageFormat buildPageFormat(
    PaperSize size, {
    double extraRightMarginMm = 0.0,
  }) {
    final verticalMargin = ticketMarginVertical(size) * PdfPageFormat.mm;
    return PdfPageFormat(
      ticketWidth(size) * PdfPageFormat.mm,
      double.infinity,
      marginLeft: ticketMarginLeft(size) * PdfPageFormat.mm,
      marginRight: ticketMarginRight(size, extraRightMarginMm: extraRightMarginMm) * PdfPageFormat.mm,
      marginTop: verticalMargin,
      marginBottom: verticalMargin,
    );
  }

  static double logoSize(PaperSize size) => size == PaperSize.mm58 ? 50.0 : 90.0;
  static Future<pw.Font?> ticketFont(PaperSize size) async {
    if (size == PaperSize.mm58) {
      _font ??= pw.Font.ttf(await rootBundle.load('assets/fonts/RobotoMono.ttf'));
      return _font!;
    }
    return null;
  }

  static Future<pw.Font?> ticketFontBold(PaperSize size) async {
    if (size == PaperSize.mm58) {
      _fontBold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/RobotoMono-semibold.ttf'));
      return _fontBold!;
    }
    return null;
  }

  static Future<pw.Font> ticketFallbackFont() async {
    _fallbackFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    return _fallbackFont!;
  }
}

enum PaperSize { mm58, mm80 }
