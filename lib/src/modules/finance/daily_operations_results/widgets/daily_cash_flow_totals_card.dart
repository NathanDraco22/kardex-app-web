import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/section_card.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/summary_row_item.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyCashFlowTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const DailyCashFlowTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // 1. Tarjetas
    final cardInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.card);
    final cardReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.card);
    final totalTarjetas = cardInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        cardReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countTarjetas = cardInvoices.length + cardReceipts.length;

    // 2. Transferencias
    final transferInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.transfer);
    final transferReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.transfer);
    final totalTransferencias = transferInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        transferReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countTransferencias = transferInvoices.length + transferReceipts.length;

    // 3. Facturas Contado (Efectivo)
    final cashInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.cash);
    final totalFacturasContado = cashInvoices.fold<int>(0, (prev, inv) => prev + inv.total);
    final countFacturasContado = cashInvoices.length;

    // 4. Abonos Contado (Efectivo)
    final cashReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.cash);
    final totalAbonosContado = cashReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countAbonosContado = cashReceipts.length;

    // Total General de Ingresos
    final totalIngresos = totalTarjetas + totalTransferencias + totalFacturasContado + totalAbonosContado;

    return SectionCard(
      title: "Ingresos (Flujo de Caja)",
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.purple.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SummaryRowItem(
            icon: Icons.credit_card_rounded,
            title: "Tarjetas",
            subtitle: "$countTarjetas movimientos",
            total: totalTarjetas,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.account_balance_rounded,
            title: "Transferencias",
            subtitle: "$countTransferencias movimientos",
            total: totalTransferencias,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.point_of_sale_rounded,
            title: "Facturas Contado (Efectivo)",
            subtitle: "$countFacturasContado movimientos",
            total: totalFacturasContado,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.receipt_long_rounded,
            title: "Abonos Contado (Efectivo)",
            subtitle: "$countAbonosContado movimientos",
            total: totalAbonosContado,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.savings_rounded,
            title: "Total General",
            subtitle: "Total ingresos reales de caja",
            total: totalIngresos,
            totalColor: Colors.purple.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
