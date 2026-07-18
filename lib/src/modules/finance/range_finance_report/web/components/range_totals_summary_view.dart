import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class RangeTotalsSummaryView extends StatelessWidget {
  final TotalsResult result;

  const RangeTotalsSummaryView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _buildInvoicesSection(),
        const SizedBox(height: 16),
        _buildIngresosSection(),
        const SizedBox(height: 16),
        _buildCreditsControlSection(),
        const SizedBox(height: 16),
        _buildReceiptsSection(),
      ],
    );
  }

  Widget _buildInvoicesSection() {
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

    return _SectionCard(
      title: "Resumen de Ventas",
      icon: Icons.point_of_sale,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRowItem(
            icon: Icons.monetization_on_outlined,
            title: "Ventas Contado",
            subtitle: "$countCashSales documentos",
            total: totalCashSales,
            cost: totalCashSalesCost,
            utility: utilityCashSales,
            totalColor: Colors.black87,
          ),
          _SummaryRowItem(
            icon: Icons.credit_score_outlined,
            title: "Ventas Crédito",
            subtitle: "$countCreditSales documentos",
            total: totalCreditSales,
            cost: totalCreditSalesCost,
            utility: utilityCreditSales,
            totalColor: Colors.black87,
          ),
          _SummaryRowItem(
            icon: Icons.insert_chart,
            title: "Total Ventas",
            subtitle: "Ventas consolidadas",
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

  Widget _buildIngresosSection() {
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

    // 3. Efectivo (Facturas Contado Efectivo + Abonos Efectivo)
    final cashInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.cash);
    final cashReceipts = result.detailReceipts.where((rec) => rec.paymentMethod == PaymentMethod.cash);
    final totalEfectivo =
        cashInvoices.fold<int>(0, (prev, inv) => prev + inv.total) +
        cashReceipts.fold<int>(0, (prev, rec) => prev + rec.total);
    final countEfectivo = cashInvoices.length + cashReceipts.length;

    // Total General de Ingresos Reales
    final totalIngresos = totalTarjetas + totalTransferencias + totalEfectivo;

    return _SectionCard(
      title: "Flujo de Caja",
      icon: Icons.account_balance_wallet_outlined,
      color: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRowItem(
            icon: Icons.money_outlined,
            title: "Efectivo",
            subtitle: "$countEfectivo movimientos (Ventas + Abonos)",
            total: totalEfectivo,
            totalColor: Colors.black87,
          ),
          _SummaryRowItem(
            icon: Icons.credit_card_outlined,
            title: "Tarjetas",
            subtitle: "$countTarjetas movimientos (Ventas + Abonos)",
            total: totalTarjetas,
            totalColor: Colors.black87,
          ),
          _SummaryRowItem(
            icon: Icons.account_balance_outlined,
            title: "Transferencias Bancarias",
            subtitle: "$countTransferencias movimientos (Ventas + Abonos)",
            total: totalTransferencias,
            totalColor: Colors.black87,
          ),
          _SummaryRowItem(
            icon: Icons.savings_outlined,
            title: "Total Ingresos Reales",
            subtitle: "Flujo consolidado de caja",
            total: totalIngresos,
            totalColor: Colors.purple,
            isDestacado: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsControlSection() {
    final creditInvoices = result.detailInvoices.where((inv) => inv.paymentType == PaymentType.credit);

    final countTotal = creditInvoices.length;
    final totalCredito = creditInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    final creditPaidInvoices = creditInvoices.where((inv) => inv.status == InvoiceStatus.paid);
    final countPaid = creditPaidInvoices.length;
    final totalPaid = creditPaidInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    final creditPendingInvoices = creditInvoices.where((inv) => inv.status != InvoiceStatus.paid);
    final countPending = creditPendingInvoices.length;
    final totalPending = creditPendingInvoices.fold<int>(0, (prev, inv) => prev + inv.total);

    return _SectionCard(
      title: "Control de Créditos",
      icon: Icons.assignment_outlined,
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRowItem(
            icon: Icons.assignment_turned_in_outlined,
            title: "Créditos Liquidados (Pagados)",
            subtitle: "$countPaid facturas canceladas en su totalidad",
            total: totalPaid,
            totalColor: Colors.green,
          ),
          _SummaryRowItem(
            icon: Icons.assignment_late_outlined,
            title: "Créditos Pendientes (Por Cobrar)",
            subtitle: "$countPending facturas con saldo pendiente",
            total: totalPending,
            totalColor: Colors.redAccent,
          ),
          _SummaryRowItem(
            icon: Icons.assignment,
            title: "Total Créditos Otorgados",
            subtitle: "Consolidado de créditos: $countTotal facturas",
            total: totalCredito,
            totalColor: Colors.orange,
            isDestacado: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsSection() {
    final int totalGeneral = result.receipts.fold<int>(0, (prev, element) => prev + element.total);
    final int totalCount = result.detailReceipts.length;

    return _SectionCard(
      title: "Abonos Recibidos",
      icon: Icons.payments_outlined,
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.receipts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "No hay abonos registrados en este rango.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          for (final receipt in result.receipts)
            _SummaryRowItem(
              icon: Icons.receipt_long,
              title: receipt.paymentMethod?.display ?? "Sin especificar",
              subtitle: "${receipt.count} abonos",
              total: receipt.total,
              totalColor: Colors.black87,
            ),
          _SummaryRowItem(
            icon: Icons.account_balance_wallet,
            title: "Total Recaudado",
            subtitle: "Consolidado de abonos: $totalCount recibos emitidos",
            total: totalGeneral,
            totalColor: Colors.green,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
