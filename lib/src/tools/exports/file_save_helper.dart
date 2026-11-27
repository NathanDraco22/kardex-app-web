import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:kardex_business/kardex_business.dart';

/// Utilidad compartida para descargar archivos binarios (PDF, PNG, etc.)
/// en Web, Desktop y Móvil sin duplicar lógica de guardado.
class FileSaveHelper {
  /// Construye un nombre de archivo seguro para estados de cuenta y liquidaciones.
  static String buildStatementFileName({
    required String prefix,
    required String clientName,
    DateTime? date,
  }) {
    final sanitizedClient = clientName
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final dateStr = DateTimeTool.formatyyyyMMdd(date ?? DateTime.now());
    return '${prefix}_${sanitizedClient.isEmpty ? "cliente" : sanitizedClient}_$dateStr';
  }

  /// Guarda [bytes] en el dispositivo o inicia descarga en navegador.
  static Future<String?> saveBytes({
    required String baseName,
    required Uint8List bytes,
    required String fileExtension,
    required MimeType mimeType,
    String dialogTitle = 'Guardar archivo',
  }) async {
    if (kIsWeb) {
      return FileSaver.instance.saveFile(
        name: baseName,
        bytes: bytes,
        fileExtension: fileExtension,
        mimeType: mimeType,
      );
    }

    try {
      return await FileSaver.instance.saveAs(
        name: baseName,
        bytes: bytes,
        fileExtension: fileExtension,
        mimeType: mimeType,
        dialogTitle: dialogTitle,
      );
    } catch (error) {
      debugPrint(
        'No se pudo abrir el diálogo Guardar como: $error. '
        'Guardando archivo directamente en Descargas.',
      );
      return FileSaver.instance.saveFile(
        name: baseName,
        bytes: bytes,
        fileExtension: fileExtension,
        mimeType: mimeType,
      );
    }
  }
}
