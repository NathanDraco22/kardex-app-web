import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/cash_counter_pdf_template.dart';
import 'package:kardex_app_front/src/tools/printers/cash_counter_ticket_printer.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:toastification/toastification.dart';

import 'cash_counter_models.dart';

class CashCounterExportDialog extends StatelessWidget {
  final CashCountRecord record;
  final BranchInDb branch;
  final String? userName;
  final double? expectedCash;

  const CashCounterExportDialog({
    super.key,
    required this.record,
    required this.branch,
    this.userName,
    this.expectedCash,
  });

  static Future<void> show(
    BuildContext context, {
    required CashCountRecord record,
    required BranchInDb branch,
    String? userName,
    double? expectedCash,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CashCounterExportDialog(
        record: record,
        branch: branch,
        userName: userName,
        expectedCash: expectedCash,
      ),
    );
  }

  Future<void> _exportFullPage(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final template = CashCounterPdfTemplate(
        record: record,
        branch: branch,
        userName: userName,
        date: record.date,
        expectedCash: expectedCash,
      );
      final dateStr = DateFormat('yyyyMMdd').format(record.date);
      await PdfExportTool.export(
        template,
        fileName: 'arqueo_hoja_completa_$dateStr.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error al exportar'),
          description: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _exportTicket(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final paperSize = await PrintManager.getLocalPaperSize();
      await printCashCounterTicket(
        record,
        branch,
        userName: userName,
        expectedCash: expectedCash,
        paperSize: paperSize,
      );
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error al imprimir ticket'),
          description: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: Colors.teal),
          SizedBox(width: 10),
          Text('Exportar Arqueo a PDF', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccione el formato en el que desea generar o imprimir el arqueo físico de caja:',
              style: TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.description_rounded,
              iconColor: Colors.teal.shade700,
              iconBgColor: Colors.teal.shade50,
              title: 'Hoja Completa (A4 / Carta)',
              subtitle: 'Formato formal con membrete, tablas detalladas de denominaciones y firmas de entrega.',
              onTap: () => _exportFullPage(context),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              icon: Icons.receipt_long_rounded,
              iconColor: Colors.deepOrange.shade700,
              iconBgColor: Colors.deepOrange.shade50,
              title: 'Rollo Térmico (Ticket POS)',
              subtitle: 'Formato angosto para impresora térmica (80mm / 58mm). Solo imprime denominaciones activas.',
              onTap: () => _exportTicket(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
