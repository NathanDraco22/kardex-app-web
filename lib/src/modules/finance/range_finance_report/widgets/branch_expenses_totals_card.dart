import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'section_card.dart';
import 'summary_row_item.dart';

class BranchExpensesTotalsCard extends StatelessWidget {
  final TotalsResult result;

  const BranchExpensesTotalsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final expenses = result.expenses;
    if (expenses == null) {
      return const SizedBox.shrink();
    }

    if (expenses.count == 0) {
      return SectionCard(
        title: "Gastos / Egresos",
        icon: Icons.trending_down_rounded,
        color: Colors.red.shade700,
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "No hay gastos registrados en este rango.",
            style: TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedByType = [...expenses.byType]..sort((a, b) => _typeOrder(a.type).compareTo(_typeOrder(b.type)));

    return SectionCard(
      title: "Gastos / Egresos",
      icon: Icons.trending_down_rounded,
      color: Colors.red.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in sortedByType) _buildTypeRow(item),
          SummaryRowItem(
            icon: Icons.check_circle_outline_rounded,
            title: "Gastos Pagados",
            subtitle: "Liquidados en su totalidad",
            total: expenses.paid,
            totalColor: Colors.green.shade700,
          ),
          SummaryRowItem(
            icon: Icons.schedule_rounded,
            title: "Gastos Pendientes",
            subtitle: "Por pagar",
            total: expenses.pending,
            totalColor: Colors.orange.shade800,
          ),
          SummaryRowItem(
            icon: Icons.account_balance_wallet_outlined,
            title: "Total Gastos",
            subtitle: "Consolidado: ${expenses.count} gastos",
            total: expenses.total,
            totalColor: Colors.red.shade800,
            isDestacado: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(ExpenseTypeTotal item) {
    final style = _ExpenseTypeStyle.forType(item.type);
    return SummaryRowItem(
      icon: style.icon,
      title: style.title,
      subtitle: "${item.count} gastos",
      total: item.total,
      totalColor: style.color,
    );
  }

  int _typeOrder(ExpenseType? type) {
    switch (type) {
      case ExpenseType.operative:
        return 0;
      case ExpenseType.supplier:
        return 1;
      case ExpenseType.tax:
        return 2;
      case null:
        return 3;
    }
  }
}

class _ExpenseTypeStyle {
  final String title;
  final IconData icon;
  final Color color;

  const _ExpenseTypeStyle({
    required this.title,
    required this.icon,
    required this.color,
  });

  factory _ExpenseTypeStyle.forType(ExpenseType? type) {
    switch (type) {
      case ExpenseType.operative:
        return _ExpenseTypeStyle(
          title: "Gastos Operativos",
          icon: Icons.business_center_rounded,
          color: Colors.indigo.shade700,
        );
      case ExpenseType.supplier:
        return _ExpenseTypeStyle(
          title: "Gastos a Proveedores",
          icon: Icons.local_shipping_rounded,
          color: Colors.teal.shade700,
        );
      case ExpenseType.tax:
        return _ExpenseTypeStyle(
          title: "Impuestos",
          icon: Icons.account_balance_rounded,
          color: Colors.purple.shade700,
        );
      case null:
        return _ExpenseTypeStyle(
          title: "Otros Gastos",
          icon: Icons.receipt_long_rounded,
          color: Colors.blueGrey.shade700,
        );
    }
  }
}
