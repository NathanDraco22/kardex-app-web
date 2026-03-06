import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

class CsvExportTool {
  static Future<void> exportProductSalesToCSV({
    required List<ProductSalesTotal> products,
    required String fileName,
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
}
