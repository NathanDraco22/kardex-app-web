import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'section_card.dart';
import 'summary_row_item.dart';

class BranchCreditControlCard extends StatelessWidget {
  final TotalsResult result;

  const BranchCreditControlCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final creditInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.credit);

    final countTotal = creditInvoices.length;
    final totalCredito = creditInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    final creditPaidInvoices = creditInvoices.where((inv) => inv.status == InvoiceStatus.paid);
    final countPaid = creditPaidInvoices.length;
    final totalPaid = creditPaidInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    final creditPendingInvoices = creditInvoices.where((inv) => inv.status != InvoiceStatus.paid);
    final countPending = creditPendingInvoices.length;
    final totalPending = creditPendingInvoices.fold<int>(0, (prev, inv) => prev + inv.totalRemaining);

    return SectionCard(
      title: "Control de Créditos",
      icon: Icons.assignment_rounded,
      color: Colors.orange.shade800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SummaryRowItem(
            icon: Icons.assignment_turned_in_rounded,
            title: "Créditos Liquidados (Pagados)",
            subtitle: "$countPaid facturas canceladas en su totalidad",
            total: totalPaid,
            totalColor: Colors.green.shade700,
          ),
          SummaryRowItem(
            icon: Icons.assignment_late_rounded,
            title: "Créditos Pendientes (Por Cobrar)",
            subtitle: "$countPending facturas con saldo pendiente",
            total: totalPending,
            totalColor: Colors.red.shade700,
          ),
          SummaryRowItem(
            icon: Icons.assignment_rounded,
            title: "Total Créditos Otorgados",
            subtitle: "Consolidado de créditos: $countTotal facturas",
            total: totalCredito,
            totalColor: Colors.orange.shade900,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}
