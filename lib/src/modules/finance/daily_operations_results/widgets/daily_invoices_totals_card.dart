import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/section_card.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/summary_row_item.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyInvoicesTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const DailyInvoicesTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final int totalGeneral = result.invoices.fold<int>(0, (prev, element) => prev + element.total);
    final int totalCost = result.invoices.fold<int>(0, (prev, element) => prev + element.totalCost);
    final int utilidadGeneral = totalGeneral - totalCost;

    return SectionCard(
      title: "Facturas (Ventas del Día)",
      icon: Icons.point_of_sale_rounded,
      color: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No hay facturas registradas en este día.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          for (final invoice in result.invoices)
            SummaryRowItem(
              icon: Icons.description_rounded,
              title: invoice.displayPaymentType,
              subtitle: "${invoice.count} documentos",
              total: invoice.total,
              cost: invoice.totalCost,
              utility: invoice.total - invoice.totalCost,
              totalColor: Colors.black87,
            ),
          SummaryRowItem(
            icon: Icons.insert_chart_rounded,
            title: "Total General",
            subtitle: "Resumen de ventas del día",
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
