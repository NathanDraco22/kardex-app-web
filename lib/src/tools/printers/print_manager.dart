import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/src/services/thermal_printer/thermal_printer_types.dart';
import 'package:kardex_app_front/src/services/thermal_printer_service.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:printing/printing.dart' hide Printer;

import 'package:kardex_app_front/src/tools/printers/devolution_printer.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/order_printer.dart';
import 'package:kardex_app_front/src/tools/printers/receipt_printer.dart';

class PrintManager with HiveService {
  static const String _boxName = "LocalPrintSettings";
  static const String _paperSizeKey = "paperSize";
  static const String _isDirectPrintKey = "isDirectPrintEnabled";
  static const String _savedPrinterKey = "savedThermalPrinter";
  static const String _autoCutKey = "autoCutEnabled";
  static const String _invertColorKey = "invertColorEnabled";
  static const String _ditheringKey = "ditheringEnabled";

  /// Obtiene el tamaño de papel configurado localmente. Si no existe, retorna 80mm por defecto.
  static Future<PaperSize> getLocalPaperSize() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    final sizeString = box.get(_paperSizeKey, defaultValue: '80mm');
    return sizeString == '58mm' ? PaperSize.mm58 : PaperSize.mm80;
  }

  /// Guarda el tamaño de papel en la configuración local.
  static Future<void> saveLocalPaperSize(PaperSize size) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    final sizeString = size == PaperSize.mm58 ? '58mm' : '80mm';
    await box.put(_paperSizeKey, sizeString);
  }

  /// Consulta si la impresión térmica directa está habilitada en este terminal.
  static Future<bool> getIsDirectPrintEnabled() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    return box.get(_isDirectPrintKey, defaultValue: false) as bool;
  }

  /// Guarda si la impresión térmica directa debe estar activa.
  static Future<void> saveIsDirectPrintEnabled(bool enabled) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    await box.put(_isDirectPrintKey, enabled);
  }

  /// Consulta si el corte automático de papel está habilitado.
  static Future<bool> getAutoCutEnabled() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    return box.get(_autoCutKey, defaultValue: true) as bool;
  }

  /// Guarda si el corte automático de papel está habilitado.
  static Future<void> saveAutoCutEnabled(bool enabled) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    await box.put(_autoCutKey, enabled);
  }

  /// Consulta si la inversión de colores (blanco/negro) está habilitada.
  static Future<bool> getInvertColorEnabled() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    return box.get(_invertColorKey, defaultValue: false) as bool;
  }

  /// Guarda si la inversión de colores (blanco/negro) debe estar activa.
  static Future<void> saveInvertColorEnabled(bool enabled) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    await box.put(_invertColorKey, enabled);
  }

  /// Consulta si el tramado Floyd-Steinberg (halftone) está habilitado.
  static Future<bool> getDitheringEnabled() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    return box.get(_ditheringKey, defaultValue: true) as bool;
  }

  /// Guarda si el tramado Floyd-Steinberg (halftone) debe estar activo.
  static Future<void> saveDitheringEnabled(bool enabled) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    await box.put(_ditheringKey, enabled);
  }

  /// Obtiene la impresora térmica directa guardada en configuración local.
  static Future<Printer?> getSavedPrinter() async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    final raw = box.get(_savedPrinterKey);
    if (raw == null) return null;
    try {
      if (raw is Map) {
        return Printer.fromJson(Map<String, dynamic>.from(raw));
      } else if (raw is String) {
        return Printer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[PrintManager] Error al parsear impresora guardada: $e');
    }
    return null;
  }

  /// Guarda o elimina la impresora térmica configurada para este terminal.
  static Future<void> saveSavedPrinter(Printer? printer) async {
    final hiveService = PrintManager();
    final box = await hiveService.getBox(_boxName);
    if (printer == null) {
      await box.delete(_savedPrinterKey);
    } else {
      await box.put(_savedPrinterKey, printer.toJson());
    }
  }

  /// Emite un documento PDF al destino configurado:
  /// Si la impresión térmica directa está activa y hay una impresora vinculada,
  /// se envía directamente en 1 solo clic.
  /// En caso contrario o si falla la conexión, recurre al diálogo del sistema (Spooler).
  static Future<bool> printPdf(
    Uint8List bytes, {
    required String name,
    required PaperSize paperSize,
  }) async {
    final isDirect = await getIsDirectPrintEnabled();
    final savedPrinter = await getSavedPrinter();

    if (!kIsWeb && isDirect && savedPrinter != null) {
      final autoCut = await getAutoCutEnabled();
      final invertColor = await getInvertColorEnabled();
      final useDithering = await getDitheringEnabled();
      try {
        final success = await getIt<ThermalPrinterService>().printPdfBytes(
          bytes,
          printer: savedPrinter,
          paperSize: paperSize,
          autoCut: autoCut,
          invertColor: invertColor,
          useDithering: useDithering,
        );
        if (success) {
          return true;
        }
      } catch (e) {
        debugPrint('[PrintManager] Falló impresión directa: $e. Usando spooler del sistema como respaldo.');
      }
    }

    // Fallback: Administrador de impresión nativo del sistema
    return await Printing.layoutPdf(onLayout: (_) => bytes, name: name);
  }

  /// Imprime el documento correspondiente según su tipo en tiempo de ejecución.
  static Future<bool> printDocument(dynamic document, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
    if (document is InvoiceInDb) {
      return await printInvoice(document, branch, paperSize: paperSize);
    } else if (document is OrderInDb) {
      return await printOrder(document, branch, paperSize: paperSize);
    } else if (document is DevolutionInDb) {
      return await printDevolution(document, branch, paperSize: paperSize);
    } else if (document is ReceiptInDb) {
      return await printReceipt(document, branch, paperSize: paperSize);
    } else {
      throw ArgumentError('Tipo de documento no soportado para impresión: ${document.runtimeType}');
    }
  }

  /// Comparte el documento en PDF según su tipo en tiempo de ejecución.
  static Future<bool> shareDocument(dynamic document, BranchInDb branch, {PaperSize paperSize = PaperSize.mm80}) async {
    if (document is InvoiceInDb) {
      return await shareInvoice(document, branch, paperSize: paperSize);
    } else if (document is OrderInDb) {
      return await shareOrder(document, branch, paperSize: paperSize);
    } else if (document is DevolutionInDb) {
      return await shareDevolution(document, branch, paperSize: paperSize);
    } else if (document is ReceiptInDb) {
      return await shareReceipt(document, branch, paperSize: paperSize);
    } else {
      throw ArgumentError('Tipo de documento no soportado para compartir: ${document.runtimeType}');
    }
  }
}
