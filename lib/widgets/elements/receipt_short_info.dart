import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class ReceiptShortInfo extends StatelessWidget {
  const ReceiptShortInfo({
    super.key,
    required this.receipt,
  });

  final ReceiptInDb receipt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              receipt.docNumber,
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
                color: Colors.blueGrey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                receipt.paymentMethod.display,
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
                receipt.clientInfo.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              NumberFormatter.convertToMoneyLike(receipt.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                final receiptDay = receipt.createdAt.copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                );

                late String label;

                if (receiptDay.isAtSameMomentAs(todayMidnight)) {
                  label = "Hoy";
                } else if (receiptDay.isAtSameMomentAs(todayMidnight.subtract(const Duration(days: 1)))) {
                  label = "Ayer";
                } else {
                  label = DateTimeTool.formatdMMeS(receipt.createdAt);
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
              receipt.createdBy.name,
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
