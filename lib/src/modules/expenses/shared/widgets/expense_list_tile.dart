import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_table_header.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Fila de la tabla desktop de gastos.
class ExpenseTableRow extends StatefulWidget {
  const ExpenseTableRow({
    super.key,
    required this.expense,
    required this.config,
    required this.isNew,
    required this.isUpdated,
    required this.onTap,
    this.showDivider = true,
  });

  final ExpenseInDb expense;
  final ExpenseListConfig config;
  final bool isNew;
  final bool isUpdated;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  State<ExpenseTableRow> createState() => _ExpenseTableRowState();
}

class _ExpenseTableRowState extends State<ExpenseTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final config = widget.config;
    final isOverdue = isExpenseOverdue(expense);
    final description = _expenseSubtitle(expense, config);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _isHovered ? config.accentColor.withValues(alpha: 0.035) : Colors.white,
          border: widget.showDivider
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: ExpenseTableLayout.horizontalPadding.copyWith(top: 11, bottom: 11),
              child: Row(
                children: [
                  Expanded(
                    flex: ExpenseTableLayout.conceptFlex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expenseConcept(expense, config),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (description != null) ...[
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
                  Expanded(
                    flex: ExpenseTableLayout.documentFlex,
                    child: Text(
                      expense.docNumber.isEmpty ? '—' : expense.docNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ExpenseTableLayout.dateFlex,
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
                    flex: ExpenseTableLayout.dueDateFlex,
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
                        color: isOverdue ? AppThemeTokens.danger : const Color(0xFF475569),
                        fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ExpenseTableLayout.statusFlex,
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        ExpenseStatusBadge(status: expense.status, compact: true),
                        if (isOverdue) const ExpenseOverdueBadge(compact: true),
                        ExpenseActivityBadge(
                          isNew: widget.isNew,
                          isUpdated: widget.isUpdated,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: ExpenseTableLayout.amountFlex,
                    child: Text(
                      NumberFormatter.convertToMoneyLike(expense.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: config.accentColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ExpenseTableLayout.actionsWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _ExpenseActionsMenu(
                        expense: expense,
                        config: config,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de gasto para móvil y tablet.
class ExpenseCardTile extends StatefulWidget {
  const ExpenseCardTile({
    super.key,
    required this.expense,
    required this.config,
    required this.isNew,
    required this.isUpdated,
    required this.onTap,
    this.inContinuousCard = false,
    this.index = 0,
  });

  final ExpenseInDb expense;
  final ExpenseListConfig config;
  final bool isNew;
  final bool isUpdated;
  final VoidCallback onTap;
  final bool inContinuousCard;
  final int index;

  @override
  State<ExpenseCardTile> createState() => _ExpenseCardTileState();
}

class _ExpenseCardTileState extends State<ExpenseCardTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final config = widget.config;
    final isOverdue = isExpenseOverdue(expense);
    final description = _expenseSubtitle(expense, config);
    final dueDate = expense.expirationDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!);

    final content = Padding(
      padding: EdgeInsets.all(widget.inContinuousCard ? 11 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: config.accentColor.withValues(alpha: 0.12),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(color: config.accentColor.withValues(alpha: 0.24)),
                ),
                child: Icon(config.icon, color: config.accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _expenseConcept(expense, config),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormatter.convertToMoneyLike(expense.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: config.accentColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Monto',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaItem(
                icon: Icons.receipt_long_rounded,
                text: expense.docNumber.isEmpty ? 'Sin documento' : 'Doc. ${expense.docNumber}',
              ),
              _MetaItem(
                icon: Icons.calendar_today_rounded,
                text: 'Reg. ${DateTimeTool.formatddMMyyEs(expense.createdAt)}',
              ),
              if (dueDate != null)
                _MetaItem(
                  icon: Icons.event_rounded,
                  text: 'Vence ${DateTimeTool.formatddMMyyEs(dueDate)}',
                  color: isOverdue ? AppThemeTokens.danger : null,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ExpenseStatusBadge(status: expense.status, compact: true),
                    if (isOverdue) const ExpenseOverdueBadge(compact: true),
                    ExpenseActivityBadge(
                      isNew: widget.isNew,
                      isUpdated: widget.isUpdated,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ExpenseActionsMenu(
                expense: expense,
                config: config,
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.inContinuousCard) {
      return Material(
        color: RowColorTool.getRowColor(widget.index),
        child: InkWell(
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppThemeTokens.borderRadiusLg,
          border: Border.all(
            color: _isHovered ? config.accentColor.withValues(alpha: 0.45) : AppThemeTokens.borderLight,
            width: _isHovered ? 1.2 : 1,
          ),
          boxShadow: _isHovered
              ? AppThemeTokens.hoverCardShadow(accent: config.accentColor)
              : AppThemeTokens.subtleCardShadow(),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppThemeTokens.borderRadiusLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF64748B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            color: effectiveColor,
            fontWeight: color == null ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ExpenseActionsMenu extends StatelessWidget {
  const _ExpenseActionsMenu({
    required this.expense,
    required this.config,
  });

  final ExpenseInDb expense;
  final ExpenseListConfig config;

  @override
  Widget build(BuildContext context) {
    final canEditOrDelete = ExpenseActionPermissions.canEditOrDelete(expense);
    final canMarkAsPaid = ExpenseActionPermissions.canMarkAsPaid(expense);

    if (!canEditOrDelete && !canMarkAsPaid) {
      return const SizedBox(width: 34, height: 34);
    }

    return PopupMenuButton<ExpenseRowAction>(
      tooltip: 'Acciones',
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF64748B)),
      splashRadius: 18,
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) => [
        if (canEditOrDelete)
          PopupMenuItem(
            value: ExpenseRowAction.edit,
            child: _menuItem(
              icon: Icons.edit_outlined,
              label: 'Editar',
              color: const Color(0xFF334155),
            ),
          ),
        if (canMarkAsPaid)
          PopupMenuItem(
            value: ExpenseRowAction.markAsPaid,
            child: _menuItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Marcar como pagado',
              color: AppThemeTokens.success,
            ),
          ),
        if (canEditOrDelete)
          PopupMenuItem(
            value: ExpenseRowAction.delete,
            child: _menuItem(
              icon: Icons.delete_outline_rounded,
              label: 'Eliminar',
              color: AppThemeTokens.danger,
            ),
          ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, ExpenseRowAction action) async {
    switch (action) {
      case ExpenseRowAction.edit:
        await ExpenseActions.edit(
          context,
          expense,
          openEditor: config.onEdit,
        );
        break;
      case ExpenseRowAction.markAsPaid:
        await ExpenseActions.markAsPaid(context, expense);
        break;
      case ExpenseRowAction.delete:
        await ExpenseActions.delete(context, expense);
        break;
    }
  }
}

String _expenseConcept(ExpenseInDb expense, ExpenseListConfig config) {
  if (config.expenseType == ExpenseType.supplier) {
    return expense.supplierName.trim().isEmpty ? '—' : expense.supplierName;
  }
  return expense.category.trim().isEmpty ? '—' : expense.category;
}

String? _expenseSubtitle(ExpenseInDb expense, ExpenseListConfig config) {
  final description = expense.description?.trim() ?? '';
  if (description.isNotEmpty) return description;
  if (config.expenseType == ExpenseType.supplier && expense.category.trim().isNotEmpty) {
    return expense.category;
  }
  return null;
}
