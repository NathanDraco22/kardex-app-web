import 'dart:async';
import 'dart:typed_data';

import 'package:kardex_app_front/src/services/thermal_printer/thermal_printer_types.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';

/// Implementación no-op para web.
///
/// La impresión térmica directa no está disponible en navegador. Esta fachada
/// evita que `flutter_thermal_printer` se compile en web y permite que
/// [PrintManager] use el diálogo de impresión del navegador como respaldo.
class ThermalPrinterService {
  Stream<List<Printer>> get devicesStream =>
      const Stream<List<Printer>>.empty();

  Printer? get activePrinter => null;

  bool get isScanning => false;

  Future<bool> requestPermissions() async => false;

  Future<void> startScan() async {}

  Future<void> stopScan() async {}

  Future<bool> connect(Printer printer) async => false;

  Future<void> disconnect([Printer? printer]) async {}

  Future<bool> printPdfBytes(
    Uint8List pdfBytes, {
    required Printer printer,
    required PaperSize paperSize,
    bool autoCut = true,
    bool invertColor = false,
    bool useDithering = true,
  }) async {
    return false;
  }

  Future<bool> printTestTicket({
    required Printer printer,
    required PaperSize paperSize,
    bool autoCut = true,
  }) async {
    return false;
  }
}
