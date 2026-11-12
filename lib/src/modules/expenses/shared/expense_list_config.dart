import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

/// Configuración que adapta la lista compartida de gastos a cada tipo.
class ExpenseListConfig {
  const ExpenseListConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.expenseType,
    required this.conceptLabel,
    required this.searchHint,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.createButtonLabel,
    required this.onCreate,
    required this.onEdit,
    required this.onOpenViewer,
    this.supportsCategoryFilter = false,
    this.supportsSupplierFilter = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final ExpenseType expenseType;

  /// Etiqueta del concepto principal: "Categoría" o "Proveedor".
  final String conceptLabel;

  final String searchHint;
  final String emptyTitle;
  final String emptySubtitle;
  final String createButtonLabel;

  final bool supportsCategoryFilter;
  final bool supportsSupplierFilter;

  final Future<ExpenseInDb?> Function(BuildContext context) onCreate;
  final Future<ExpenseInDb?> Function(BuildContext context, ExpenseInDb expense) onEdit;
  final Future<void> Function(BuildContext context, ExpenseInDb expense) onOpenViewer;
}
