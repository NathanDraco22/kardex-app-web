import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_business/kardex_business.dart';
import 'bank_breakdown_sublist.dart';
import 'section_card.dart';
import 'summary_row_item.dart';

class BranchCashFlowTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const BranchCashFlowTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // 1. Tarjetas
    final cardInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.card);
    final cardReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.card);
    final totalTarjetas =
        cardInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        cardReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countTarjetas = cardInvoices.length + cardReceipts.length;

    // 2. Transferencias
    final transferInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.transfer);
    final transferReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.transfer);
    final totalTransferencias =
        transferInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        transferReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countTransferencias = transferInvoices.length + transferReceipts.length;

    final cardByBank = groupReferencesByBank([
      ...cardInvoices.map((inv) => (bankReference: inv.bankReference, amount: inv.total)),
      ...cardReceipts.map((rec) => (bankReference: rec.bankReference, amount: rec.total)),
    ]);
    final transferByBank = groupReferencesByBank([
      ...transferInvoices.map((inv) => (bankReference: inv.bankReference, amount: inv.total)),
      ...transferReceipts.map((rec) => (bankReference: rec.bankReference, amount: rec.total)),
    ]);

    // 3. Efectivo (Facturas Contado Efectivo + Abonos Efectivo)
    final cashInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.cash);
    final cashReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.cash);
    final totalEfectivo =
        cashInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        cashReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countEfectivo = cashInvoices.length + cashReceipts.length;

    // Total General de Ingresos Reales
    final totalIngresos = totalTarjetas + totalTransferencias + totalEfectivo;

    return SectionCard(
      title: "Flujo de Caja Real",
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.purple.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SummaryRowItem(
            icon: Icons.payments_outlined,
            title: "Efectivo",
            subtitle: "$countEfectivo movimientos (Ventas + Abonos)",
            total: totalEfectivo,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.credit_card_rounded,
            title: "Tarjetas",
            subtitle: "$countTarjetas movimientos (Ventas + Abonos)",
            total: totalTarjetas,
            totalColor: Colors.black87,
          ),
          if (cardByBank.isNotEmpty) BankBreakdownSublist(entries: cardByBank),
          SummaryRowItem(
            icon: Icons.account_balance_rounded,
            title: "Transferencias Bancarias",
            subtitle: "$countTransferencias movimientos (Ventas + Abonos)",
            total: totalTransferencias,
            totalColor: Colors.black87,
          ),
          if (transferByBank.isNotEmpty) BankBreakdownSublist(entries: transferByBank),
          SummaryRowItem(
            icon: Icons.savings_rounded,
            title: "Total Ingresos Reales",
            subtitle: "Flujo consolidado de caja",
            total: totalIngresos,
            totalColor: Colors.purple.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
