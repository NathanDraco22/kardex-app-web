import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class TotalsSummaryView extends StatelessWidget {
  final TotalsResult result;

  const TotalsSummaryView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      children: [
        _buildReceiptsSection(),
        const SizedBox(height: 12),
        _buildInvoicesSection(),
      ],
    );
  }

  Widget _buildReceiptsSection() {
    final int totalGeneral = result.receipts.fold<int>(0, (prev, element) => prev + element.total);

    return _SectionCard(
      title: "Recaudos (Abonos/Recibos)",
      icon: Icons.payments_outlined,
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.receipts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("No hay recaudos registrados.", style: TextStyle(color: Colors.grey)),
            ),
          for (final receipt in result.receipts)
            _SummaryRowItem(
              icon: Icons.receipt_long,
              title: receipt.paymentMethod?.display ?? "Sin especificar",
              subtitle: "${receipt.count} movimientos",
              total: receipt.total,
              totalColor: Colors.black87,
            ),
          _SummaryRowItem(
            icon: Icons.account_balance_wallet,
            title: "Total General",
            subtitle: "Todos los movimientos",
            total: totalGeneral,
            totalColor: Colors.green,
            isDestacado: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesSection() {
    final int totalGeneral = result.invoices.fold<int>(0, (prev, element) => prev + element.total);
    final int totalCost = result.invoices.fold<int>(0, (prev, element) => prev + element.totalCost);
    final int utilidadGeneral = totalGeneral - totalCost;

    return _SectionCard(
      title: "Facturas (Ventas)",
      icon: Icons.point_of_sale,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("No hay facturas registradas.", style: TextStyle(color: Colors.grey)),
            ),
          for (final invoice in result.invoices)
            _SummaryRowItem(
              icon: Icons.description,
              title: invoice.displayPaymentType,
              subtitle: "${invoice.count} documentos",
              total: invoice.total,
              cost: invoice.totalCost,
              utility: invoice.total - invoice.totalCost,
              totalColor: Colors.black87,
            ),
          _SummaryRowItem(
            icon: Icons.insert_chart,
            title: "Total General",
            subtitle: "Resumen de ventas",
            total: totalGeneral,
            cost: totalCost,
            utility: utilidadGeneral,
            totalColor: Colors.blue,
            isDestacado: true,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SummaryRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int total;
  final int? cost;
  final int? utility;
  final Color totalColor;
  final bool isDestacado;

  const _SummaryRowItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.total,
    this.cost,
    this.utility,
    this.totalColor = Colors.black,
    this.isDestacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestacado ? totalColor : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isDestacado ? totalColor.withValues(alpha: 0.05) : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: baseColor.withValues(alpha: 0.8), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isDestacado ? FontWeight.bold : FontWeight.w600,
                    fontSize: isDestacado ? 18 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormatter.convertToMoneyLike(total),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDestacado ? 20 : 18,
                  color: totalColor,
                ),
              ),
              if (cost != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Costo: ${NumberFormatter.convertToMoneyLike(cost!)}",
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
              if (utility != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Ganancia: ${NumberFormatter.convertToMoneyLike(utility!)}",
                  style: const TextStyle(
                    fontSize: 15,
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
