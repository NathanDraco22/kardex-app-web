import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:kardex_business/kardex_business.dart';

class CsvExportTool {
  static Future<String?> saveCsvContent({
    required String fileName,
    required String content,
    bool includeBom = true,
  }) async {
    final buffer = StringBuffer();

    if (includeBom) {
      buffer.write('\uFEFF');
    }

    buffer.write(content);

    final bytes = utf8.encode(buffer.toString());
    final uint8List = Uint8List.fromList(bytes);
    final baseName = fileName.toLowerCase().endsWith(".csv") ? fileName.substring(0, fileName.length - 4) : fileName;

    if (kIsWeb) {
      return FileSaver.instance.saveFile(
        name: baseName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    }

    try {
      return await FileSaver.instance.saveAs(
        name: baseName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
        dialogTitle: "Guardar plantilla CSV",
      );
    } catch (error) {
      debugPrint(
        "No se pudo abrir el diálogo Guardar como: $error. "
        "Guardando la plantilla directamente en Descargas.",
      );
      return FileSaver.instance.saveFile(
        name: baseName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    }
  }

  static Future<void> exportProductSalesToCSV({
    required List<ProductSalesTotal> products,
    required String fileName,
    String? title,
  }) async {
    if (products.isEmpty) return;

    final StringBuffer buffer = StringBuffer();

    buffer.writeln("Producto,Total Unidades,Importe");

    for (final product in products) {
      final safeName = product.productName.replaceAll('"', '""');
      final formattedTotal = NumberFormatter.convertToMoneyLike(product.total);

      buffer.writeln(
        '"$safeName",${product.totalUnits},"$formattedTotal"',
      );
    }

    final bytes = utf8.encode(buffer.toString());
    final uint8List = Uint8List.fromList(bytes);

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: fileName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    }
  }

  static Future<void> exportExpensesToCSV({
    required List<ExpenseInDb> expenses,
    required String fileName,
  }) async {
    if (expenses.isEmpty) return;

    // BOM UTF-8 para compatibilidad con Excel.
    final bytes = utf8.encode('\uFEFF${buildExpensesCsv(expenses)}');
    final uint8List = Uint8List.fromList(bytes);

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: fileName,
        bytes: uint8List,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );
    }
  }
}

/// Construye el contenido CSV del reporte de gastos sin acceder a FileSaver.
///
/// Usa la fecha de registro (`createdAt`) y el mismo criterio de tipo/concepto
/// que el reporte visual.
String buildExpensesCsv(List<ExpenseInDb> expenses) {
  final buffer = StringBuffer()..writeln("Tipo,N° Documento,Concepto,Registro,Estado,Monto");

  for (final expense in expenses) {
    final typeStr = _expenseTypeLabel(expense.type);
    final concept = _expenseConcept(expense);
    final safeConcept = concept.replaceAll('"', '""');
    final dateStr = DateTimeTool.formatddMMyyEs(expense.createdAt);
    final statusStr = _expenseStatusLabel(expense.status);
    final formattedAmount = NumberFormatter.convertToMoneyLike(expense.amount);

    buffer.writeln(
      '"$typeStr","${expense.docNumber}","$safeConcept","$dateStr","$statusStr","$formattedAmount"',
    );
  }

  return buffer.toString();
}

String _expenseTypeLabel(ExpenseType type) {
  switch (type) {
    case ExpenseType.operative:
      return 'Operativo';
    case ExpenseType.supplier:
      return 'Proveedor';
    case ExpenseType.tax:
      return 'Impuesto';
  }
}

String _expenseConcept(ExpenseInDb expense) {
  switch (expense.type) {
    case ExpenseType.operative:
      return expense.category;
    case ExpenseType.supplier:
      return expense.supplierName;
    case ExpenseType.tax:
      final category = expense.category.trim();
      if (category.isNotEmpty) return category;
      return expense.description?.trim() ?? '';
  }
}

String _expenseStatusLabel(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.draft:
      return 'Borrador';
    case ExpenseStatus.open:
      return 'Pendiente';
    case ExpenseStatus.paid:
      return 'Pagado';
    case ExpenseStatus.partiallyPaid:
      return 'Parcial';
    case ExpenseStatus.cancelled:
      return 'Cancelado';
  }
}
