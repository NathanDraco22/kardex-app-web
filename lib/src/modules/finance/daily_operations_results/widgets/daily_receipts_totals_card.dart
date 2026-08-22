import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/section_card.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/summary_row_item.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyReceiptsTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const DailyReceiptsTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final int totalGeneral = result.receipts.fold<int>(0, (prev, element) => prev + element.total);

    return SectionCard(
      title: "Recaudos (Abonos/Recibos)",
      icon: Icons.payments_rounded,
      color: Colors.green.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.receipts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No hay recaudos registrados en este día.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          for (final receipt in result.receipts)
            SummaryRowItem(
              icon: Icons.receipt_long_rounded,
              title: receipt.paymentMethod?.display ?? "Sin especificar",
              subtitle: "${receipt.count} movimientos",
              total: receipt.total,
              totalColor: Colors.black87,
            ),
          SummaryRowItem(
            icon: Icons.account_balance_wallet_rounded,
            title: "Total General",
            subtitle: "Todos los abonos del día",
            total: totalGeneral,
            totalColor: Colors.green.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
