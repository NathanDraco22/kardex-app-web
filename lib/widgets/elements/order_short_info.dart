import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class OrderShortInfo extends StatelessWidget {
  const OrderShortInfo({
    super.key,
    required this.order,
  });

  final OrderInDb order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNotOpen = order.status == OrderStatus.cancelled || order.status == OrderStatus.completed;
    final textDecoration = isNotOpen ? TextDecoration.lineThrough : null;

    final colorsMap = {
      OrderStatus.draft: Colors.amber.shade400,
      OrderStatus.open: Colors.blue.shade400,
      OrderStatus.completed: Colors.green.shade400,
      OrderStatus.cancelled: Colors.red.shade400,
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
              order.docNumber,
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
                color: colorsMap[order.status],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.tag,
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
                order.clientInfo.name,
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
              NumberFormatter.convertToMoneyLike(order.total),
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
                final orderDay = order.createdAt.copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                );

                late String label;

                if (orderDay.isAtSameMomentAs(todayMidnight)) {
                  label = "Hoy";
                } else if (orderDay.isAtSameMomentAs(todayMidnight.subtract(const Duration(days: 1)))) {
                  label = "Ayer";
                } else {
                  label = DateTimeTool.formatdMMeS(order.createdAt);
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
        // authot here
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 14,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              order.createdBy.name,
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
