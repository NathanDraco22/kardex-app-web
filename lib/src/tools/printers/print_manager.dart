import 'package:kardex_app_front/src/services/hive_service.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';

import 'package:kardex_app_front/src/tools/printers/devolution_printer.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/order_printer.dart';
import 'package:kardex_app_front/src/tools/printers/receipt_printer.dart';

class PrintManager with HiveService {
  static const String _boxName = "LocalPrintSettings";
  static const String _paperSizeKey = "paperSize";

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
      throw ArgumentError('Tipo de documento no soportado para impresión: \${document.runtimeType}');
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
      throw ArgumentError('Tipo de documento no soportado para compartir: \${document.runtimeType}');
    }
  }
}
