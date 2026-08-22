import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'section_card.dart';
import 'summary_row_item.dart';

class BranchSalesTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const BranchSalesTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cashInvoices = result.detailInvoices.where((inv) => inv.paymentType != PaymentType.credit);
    final creditInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.credit);

    final totalCashSales = cashInvoices.fold<int>(0, (prev, inv) => prev + inv.total);
    final totalCashSalesCost = cashInvoices.fold<int>(0, (prev, inv) => prev + inv.totalCost);
    final utilityCashSales = totalCashSales - totalCashSalesCost;
    final countCashSales = cashInvoices.length;

    final totalCreditSales = creditInvoices.fold<int>(0, (prev, inv) => prev + inv.total);
    final totalCreditSalesCost = creditInvoices.fold<int>(0, (prev, inv) => prev + inv.totalCost);
    final utilityCreditSales = totalCreditSales - totalCreditSalesCost;
    final countCreditSales = creditInvoices.length;

    final totalGeneral = totalCashSales + totalCreditSales;
    final totalCost = totalCashSalesCost + totalCreditSalesCost;
    final utilidadGeneral = totalGeneral - totalCost;

    return SectionCard(
      title: "Resumen de Ventas",
      icon: Icons.point_of_sale_rounded,
      color: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SummaryRowItem(
            icon: Icons.monetization_on_outlined,
            title: "Ventas Contado",
            subtitle: "$countCashSales documentos",
            total: totalCashSales,
            cost: totalCashSalesCost,
            utility: utilityCashSales,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.credit_score_outlined,
            title: "Ventas Crédito",
            subtitle: "$countCreditSales documentos",
            total: totalCreditSales,
            cost: totalCreditSalesCost,
            utility: utilityCreditSales,
            totalColor: Colors.black87,
          ),
          SummaryRowItem(
            icon: Icons.insert_chart_rounded,
            title: "Total Ventas",
            subtitle: "Ventas consolidadas",
            total: totalGeneral,
            cost: totalCost,
            utility: utilidadGeneral,
            totalColor: Colors.blue.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
