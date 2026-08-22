import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class SummaryRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int total;
  final int? cost;
  final int? utility;
  final Color totalColor;
  final bool isDestacado;

  const SummaryRowItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.total,
    this.cost,
    this.utility,
    this.totalColor = Colors.black87,
    this.isDestacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestacado ? totalColor : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDestacado ? totalColor.withValues(alpha: 0.05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: baseColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isDestacado ? FontWeight.bold : FontWeight.w600,
                    fontSize: isDestacado ? 16 : 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormatter.convertToMoneyLike(total),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDestacado ? 17 : 15,
                  color: totalColor,
                ),
              ),
              if (cost != null) ...[
                const SizedBox(height: 2),
                Text(
                  "Costo: ${NumberFormatter.convertToMoneyLike(cost!)}",
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
              if (utility != null) ...[
                const SizedBox(height: 2),
                Text(
                  "Ganancia: ${NumberFormatter.convertToMoneyLike(utility!)}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
