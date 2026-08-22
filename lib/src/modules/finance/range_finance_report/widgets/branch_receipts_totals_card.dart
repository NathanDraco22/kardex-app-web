import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'section_card.dart';
import 'summary_row_item.dart';

class BranchReceiptsTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const BranchReceiptsTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final int totalGeneral = result.receipts.fold<int>(0, (prev, element) => prev + element.total);
    final int totalCount = result.detailReceipts.length;

    return SectionCard(
      title: "Abonos Recibidos (Recibos)",
      icon: Icons.receipt_long_rounded,
      color: Colors.teal.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.receipts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "No hay abonos registrados en este rango.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          for (final receipt in result.receipts)
            SummaryRowItem(
              icon: Icons.receipt_rounded,
              title: receipt.paymentMethod?.display ?? "Sin especificar",
              subtitle: "${receipt.count} abonos",
              total: receipt.total,
              totalColor: Colors.black87,
            ),
          SummaryRowItem(
            icon: Icons.account_balance_wallet_rounded,
            title: "Total Recaudado",
            subtitle: "Consolidado de abonos: $totalCount recibos emitidos",
            total: totalGeneral,
            totalColor: Colors.teal.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
