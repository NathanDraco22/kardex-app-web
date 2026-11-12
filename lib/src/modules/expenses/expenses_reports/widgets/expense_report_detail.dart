import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Vista detallada del reporte: tabla en desktop y tarjetas en móvil.
///
/// La paginación es local para no construir hasta 2,000 filas de una vez.
class ExpenseReportDetailView extends StatefulWidget {
  const ExpenseReportDetailView({
    super.key,
    required this.items,
    required this.isDesktop,
  });

  final List<ExpenseInDb> items;
  final bool isDesktop;

  @override
  State<ExpenseReportDetailView> createState() => _ExpenseReportDetailViewState();
}

class _ExpenseReportDetailViewState extends State<ExpenseReportDetailView> {
  static const int _pageSize = 100;

  int _visibleCount = _pageSize;

  @override
  void didUpdateWidget(covariant ExpenseReportDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.items, widget.items)) {
      _visibleCount = _pageSize;
    }
  }

  void _showMore() {
    final nextCount = _visibleCount + _pageSize;
    setState(() {
      _visibleCount = nextCount >= widget.items.length ? widget.items.length : nextCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Sin gastos en el período',
        subtitle: 'No hay registros con la fecha de registro seleccionada. Prueba con otro período.',
        accentColor: AppThemeTokens.indigo,
      );
    }

    final visibleItems = widget.items.take(_visibleCount).toList(growable: false);
    final remaining = widget.items.length - visibleItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isDesktop) _buildDesktopTable(visibleItems) else _buildMobileCards(visibleItems),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: OutlinedButton.icon(
                key: const ValueKey('expense-report-show-more'),
                onPressed: _showMore,
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: Text(
                  'Mostrar más ($remaining restantes)',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.indigo,
                  side: BorderSide(color: AppThemeTokens.indigo.withValues(alpha: 0.35)),
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusMd,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopTable(List<ExpenseInDb> visibleItems) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _ExpenseTableHeader(),
          const Divider(height: 1, color: AppThemeTokens.borderLight),
          for (var index = 0; index < visibleItems.length; index++) ...[
            _ExpenseTableRow(expense: visibleItems[index]),
            if (index < visibleItems.length - 1)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileCards(List<ExpenseInDb> visibleItems) {
    return Column(
      children: [
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ExpenseReportCard(expense: visibleItems[index]),
          if (index < visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ExpenseTableHeader extends StatelessWidget {
  const _ExpenseTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF64748B),
      letterSpacing: 0.1,
    );

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 18, child: Text('Tipo', style: style)),
          Expanded(flex: 24, child: Text('Concepto', style: style)),
          Expanded(flex: 13, child: Text('Documento', style: style)),
          Expanded(flex: 12, child: Text('Registro', style: style)),
          Expanded(flex: 12, child: Text('Vencimiento', style: style)),
          Expanded(flex: 19, child: Text('Estado', style: style)),
          Expanded(
            flex: 13,
            child: Text('Monto', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTableRow extends StatelessWidget {
  const _ExpenseTableRow({required this.expense});

  final ExpenseInDb expense;

  @override
  Widget build(BuildContext context) {
    final concept = _expenseConcept(expense);
    final description = _expenseSupportingDescription(expense);
    final overdue = isExpenseOverdue(expense);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 18,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ExpenseTypeBadge(type: expense.type),
            ),
          ),
          Expanded(
            flex: 24,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concept,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                expense.docNumber.trim().isEmpty ? '—' : expense.docNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              DateTimeTool.formatddMMyyEs(expense.createdAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                expense.expirationDate == null
                    ? '—'
                    : DateTimeTool.formatddMMyyEs(
                        DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!),
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                  color: overdue ? AppThemeTokens.danger : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 19,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ExpenseStatusBadge(status: expense.status, compact: true),
                  if (overdue) const ExpenseOverdueBadge(compact: true),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: Text(
              NumberFormatter.convertToMoneyLike(expense.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseReportCard extends StatelessWidget {
  const _ExpenseReportCard({required this.expense});

  final ExpenseInDb expense;

  @override
  Widget build(BuildContext context) {
    final concept = _expenseConcept(expense);
    final description = _expenseSupportingDescription(expense);
    final overdue = isExpenseOverdue(expense);
    final expirationDate = expense.expirationDate;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ExpenseTypeBadge(type: expense.type),
              const Spacer(),
              const Icon(
                Icons.event_available_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                DateTimeTool.formatddMMyyEs(expense.createdAt),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  NumberFormatter.convertToMoneyLike(expense.amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          if (expense.docNumber.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    expense.docNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ExpenseStatusBadge(status: expense.status, compact: true),
              if (overdue) const ExpenseOverdueBadge(compact: true),
              if (expirationDate != null)
                Text(
                  'Vence: ${DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expirationDate))}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                    color: overdue ? AppThemeTokens.danger : const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseTypeBadge extends StatelessWidget {
  const _ExpenseTypeBadge({required this.type});

  final ExpenseType type;

  @override
  Widget build(BuildContext context) {
    final (label, icon, variant) = switch (type) {
      ExpenseType.operative => (
        'Operativo',
        Icons.business_center_rounded,
        AppBadgeVariant.indigo,
      ),
      ExpenseType.supplier => (
        'Proveedor',
        Icons.local_shipping_rounded,
        AppBadgeVariant.teal,
      ),
      ExpenseType.tax => (
        'Impuesto',
        Icons.receipt_long_rounded,
        AppBadgeVariant.warning,
      ),
    };

    return AppStatusBadge(
      label: label,
      icon: icon,
      variant: variant,
      fontSize: 10.5,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
    );
  }
}

String _expenseConcept(ExpenseInDb expense) {
  switch (expense.type) {
    case ExpenseType.operative:
      final category = expense.category.trim();
      return category.isEmpty ? 'Sin categoría' : category;
    case ExpenseType.supplier:
      final supplier = expense.supplierName.trim();
      return supplier.isEmpty ? 'Proveedor desconocido' : supplier;
    case ExpenseType.tax:
      final category = expense.category.trim();
      if (category.isNotEmpty) return category;
      final description = expense.description?.trim() ?? '';
      return description.isEmpty ? 'Sin categoría' : description;
  }
}

String _expenseSupportingDescription(ExpenseInDb expense) {
  final description = expense.description?.trim() ?? '';
  if (expense.type == ExpenseType.tax && expense.category.trim().isEmpty) {
    return '';
  }
  return description;
}
