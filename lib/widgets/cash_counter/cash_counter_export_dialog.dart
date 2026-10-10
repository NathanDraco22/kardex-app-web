import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/cash_counter_pdf_template.dart';
import 'package:kardex_app_front/src/tools/printers/cash_counter_ticket_printer.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

import 'cash_counter_models.dart';

enum CashCounterExportAction {
  print,
  share,
}

class CashCounterExportDialog extends StatelessWidget {
  final CashCountRecord record;
  final BranchInDb branch;
  final String? userName;
  final double? expectedCash;
  final CashCounterExportAction action;

  const CashCounterExportDialog({
    super.key,
    required this.record,
    required this.branch,
    this.userName,
    this.expectedCash,
    this.action = CashCounterExportAction.print,
  });

  /// Abre el diálogo para seleccionar formato de Impresión (Rollo o Hoja)
  static Future<void> showPrint(
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
        action: CashCounterExportAction.print,
      ),
    );
  }

  /// Abre el diálogo para seleccionar formato para Compartir (Rollo o Hoja)
  static Future<void> showShare(
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
        action: CashCounterExportAction.share,
      ),
    );
  }

  /// Compatibilidad general de exportación
  static Future<void> show(
    BuildContext context, {
    required CashCountRecord record,
    required BranchInDb branch,
    String? userName,
    double? expectedCash,
  }) {
    return showPrint(
      context,
      record: record,
      branch: branch,
      userName: userName,
      expectedCash: expectedCash,
    );
  }

  Future<void> _handleFullPage(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final template = CashCounterPdfTemplate(
        record: record,
        branch: branch,
        userName: userName,
        date: record.date,
        expectedCash: expectedCash,
      );
      final doc = await template.buildDocument();
      final bytes = await doc.save();
      final dateStr = DateFormat('yyyyMMdd').format(record.date);
      final fileName = 'arqueo_hoja_completa_$dateStr.pdf';

      if (action == CashCounterExportAction.print) {
        await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: fileName,
        );
      } else {
        await Printing.sharePdf(
          bytes: bytes,
          filename: fileName,
        );
      }
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(action == CashCounterExportAction.print ? 'Error al imprimir' : 'Error al compartir'),
          description: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _handleTicket(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      final paperSize = await PrintManager.getLocalPaperSize();
      if (action == CashCounterExportAction.print) {
        await printCashCounterTicket(
          record,
          branch,
          userName: userName,
          expectedCash: expectedCash,
          paperSize: paperSize,
        );
      } else {
        await shareCashCounterTicket(
          record,
          branch,
          userName: userName,
          expectedCash: expectedCash,
          paperSize: paperSize,
        );
      }
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(action == CashCounterExportAction.print ? 'Error al imprimir ticket' : 'Error al compartir ticket'),
          description: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrint = action == CashCounterExportAction.print;
    final titleText = isPrint ? 'Imprimir Arqueo' : 'Compartir Arqueo';
    final headerIcon = isPrint ? Icons.print_outlined : Icons.share_outlined;
    final headerColor = isPrint ? Colors.teal : Colors.deepOrange;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(headerIcon, color: headerColor),
          const SizedBox(width: 10),
          Text(titleText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isPrint
                  ? 'Seleccione el formato en el que desea imprimir el arqueo de caja:'
                  : 'Seleccione el formato en el que desea compartir el PDF del arqueo:',
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.receipt_long_rounded,
              iconColor: Colors.deepOrange.shade700,
              iconBgColor: Colors.deepOrange.shade50,
              title: 'Rollo Térmico (Ticket POS)',
              subtitle: 'Formato angosto para impresora de tickets (80mm / 58mm). Solo imprime denominaciones activas.',
              onTap: () => _handleTicket(context),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              icon: Icons.description_rounded,
              iconColor: Colors.teal.shade700,
              iconBgColor: Colors.teal.shade50,
              title: 'Hoja Completa (A4 / Carta)',
              subtitle: 'Formato formal con membrete, tablas detalladas de denominaciones y firmas de entrega.',
              onTap: () => _handleFullPage(context),
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
