import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:kardex_app_front/src/domain/models/product_stat/product_stat_in_db.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class SaleProjectionCsv {
  static Future<void> generateAndSave(
    List<ProductStatInDbWithAccount> stats,
    int projectionDays,
  ) async {
    final buffer = StringBuffer();

    // Cabecera (con BOM para Excel)
    buffer.write('\uFEFF');
    buffer.writeln(
      "Producto,Marca,Unidad,Inv. Actual,Prom. Diario,Costo Und.,Dias Proyeccion,Proyeccion,Estado,Costo Total,Clasificacion",
    );

    for (final item in stats) {
      final stock = item.account.currentStock;
      final daily = item.unitsPerDay;
      final needed = (daily * projectionDays) - stock;
      final isDeficit = needed > 0;
      final totalCost = isDeficit ? (needed * item.account.averageCostMoney) : 0;
      final estado = isDeficit ? "FALTA" : "SOBRA";

      // Sanitize fields designed to avoid CSV breaking
      final name = item.product.name.replaceAll(',', ' ');
      final brand = item.product.brandName.replaceAll(',', ' ');
      final unit = item.product.unitName.replaceAll(',', ' ');

      buffer.write('$name,');
      buffer.write('$brand,');
      buffer.write('$unit,');
      buffer.write('$stock,');
      buffer.write('${daily.toStringAsFixed(2)},');
      buffer.write('${item.account.averageCost},');
      buffer.write('$projectionDays,');
      buffer.write('${needed.toStringAsFixed(2)},');
      buffer.write('$estado,');
      buffer.write('${totalCost.toStringAsFixed(2)},');
      buffer.writeln('${item.estimationLevel}');
    }

    final now = DateTime.now();
    final fileName = "proyeccion_ventas_${DateTimeTool.formatddMMyy(now)}.csv";

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar Proyección de Ventas',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile == null) {
      // Usuario canceló
      return;
    }

    final file = File(outputFile);
    await file.writeAsString(buffer.toString());
  }
}
