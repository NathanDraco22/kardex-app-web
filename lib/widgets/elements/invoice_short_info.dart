import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class InvoiceShortInfo extends StatelessWidget {
  const InvoiceShortInfo({
    super.key,
    required this.invoice,
  });

  final InvoiceInDb invoice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNotOpen = invoice.status == InvoiceStatus.cancelled;
    final textDecoration = isNotOpen ? TextDecoration.lineThrough : null;

    final colorsMap = {
      InvoiceStatus.draft: Colors.grey.shade400,
      InvoiceStatus.open: Colors.blue.shade400,
      InvoiceStatus.paid: Colors.green.shade400,
      InvoiceStatus.partiallypaid: Colors.amber.shade400,
      InvoiceStatus.cancelled: Colors.red.shade400,
    };

    final labelsMap = {
      InvoiceStatus.draft: "Borrador",
      InvoiceStatus.open: "Abierta",
      InvoiceStatus.paid: "Pagada",
      InvoiceStatus.partiallypaid: "Abonada",
      InvoiceStatus.cancelled: "Cancelada",
    };

    final todayMidnight = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Row(
          children: [
            Icon(
              Icons.tag_rounded,
              size: 14,
              color: colorScheme.outline,
            ),
            Text(
              invoice.docNumber,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colorsMap[invoice.status],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labelsMap[invoice.status] ?? invoice.status.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                invoice.clientInfo.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: textDecoration,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              NumberFormatter.convertToMoneyLike(invoice.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: textDecoration,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Builder(
              builder: (context) {
                final invoiceDay = invoice.createdAt.copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                );

                late String label;

                if (invoiceDay.isAtSameMomentAs(todayMidnight)) {
                  label = "Hoy";
                } else if (invoiceDay.isAtSameMomentAs(todayMidnight.subtract(const Duration(days: 1)))) {
                  label = "Ayer";
                } else {
                  label = DateTimeTool.formatdMMeS(invoice.createdAt);
                }

                return Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 14,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              invoice.createdBy.name,
              style: TextStyle(
                color: colorScheme.outline,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
