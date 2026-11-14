import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:pdf/pdf.dart';

void main() {
  group('TicketSettings.buildPageFormat', () {
    test('usa margen derecho de seguridad de 5mm por defecto para 80mm', () {
      final format = TicketSettings.buildPageFormat(PaperSize.mm80);

      expect(format.width, closeTo(72.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginLeft, closeTo(2.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginRight, closeTo(5.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginTop, closeTo(2.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginBottom, closeTo(2.0 * PdfPageFormat.mm, 0.001));
    });

    test('aplica margen derecho extra dentro del rango permitido en 80mm', () {
      final format = TicketSettings.buildPageFormat(
        PaperSize.mm80,
        extraRightMarginMm: 4.0,
      );

      expect(format.marginRight, closeTo(9.0 * PdfPageFormat.mm, 0.001));

      final clampedMax = TicketSettings.buildPageFormat(
        PaperSize.mm80,
        extraRightMarginMm: 30.0,
      );
      expect(clampedMax.marginRight, closeTo(20.0 * PdfPageFormat.mm, 0.001));
    });

    test('mantiene dimensiones de 58mm sin aplicar margen extra de 80mm', () {
      final format = TicketSettings.buildPageFormat(
        PaperSize.mm58,
        extraRightMarginMm: 6.0,
      );

      expect(format.width, closeTo(50.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginLeft, closeTo(1.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginRight, closeTo(1.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginTop, closeTo(1.0 * PdfPageFormat.mm, 0.001));
      expect(format.marginBottom, closeTo(1.0 * PdfPageFormat.mm, 0.001));
    });

    test('PrintManager.getTicketPageFormat respeta override en 80mm e ignora en 58mm', () async {
      final format80 = await PrintManager.getTicketPageFormat(
        PaperSize.mm80,
        extraRightMarginMm: 3.0,
      );
      expect(format80.marginRight, closeTo(8.0 * PdfPageFormat.mm, 0.001));

      final format58 = await PrintManager.getTicketPageFormat(
        PaperSize.mm58,
        extraRightMarginMm: 3.0,
      );
      expect(format58.marginRight, closeTo(1.0 * PdfPageFormat.mm, 0.001));
    });
  });
}
