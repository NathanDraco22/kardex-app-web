import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketSettings {
  static pw.Font? _font;
  static pw.Font? _fontBold;
  static double titleFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 9.0;
  static double contentFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 9.0;
  static double ticketWidth(PaperSize size) => size == PaperSize.mm58 ? 50.0 : 72.0;
  static double ticketMargin(PaperSize size) => size == PaperSize.mm58 ? 1.0 : 2.0;
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
}

enum PaperSize { mm58, mm80 }
