import 'package:flutter/material.dart';

enum ExportOption { csv, pdf }

Future<ExportOption?> showExportOptionsDialog(BuildContext context) {
  return showDialog<ExportOption>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Opciones de Exportación"),
        content: const Text("Seleccione el formato en el que desea exportar el reporte."),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(ExportOption.csv),
            icon: const Icon(Icons.table_chart),
            label: const Text("CSV Excel"),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(ExportOption.pdf),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Reporte PDF"),
          ),
        ],
      );
    },
  );
}
