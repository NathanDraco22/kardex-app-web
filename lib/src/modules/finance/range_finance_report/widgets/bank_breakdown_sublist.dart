import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_business/kardex_business.dart';

/// Lista indentada compacta con el desglose por banco de pagos con tarjeta o transferencia.
class BankBreakdownSublist extends StatelessWidget {
  final List<BankBreakdownEntry> entries;

  const BankBreakdownSublist({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 28, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: entries.map((entry) {
          final isUnspecified = entry.bankName == kUnspecifiedBankLabel;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  size: 15,
                  color: isUnspecified ? Colors.grey : Colors.indigo.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${entry.bankName} (${entry.count})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isUnspecified ? FontWeight.w500 : FontWeight.w600,
                      color: isUnspecified
                          ? Colors.grey.shade700
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  NumberFormatter.convertToMoneyLike(entry.totalCents),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isUnspecified
                        ? Colors.grey.shade700
                        : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
