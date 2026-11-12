import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_business/kardex_business.dart';

/// Abre el visor de un gasto usando la sucursal activa de la sesión.
Future<void> showExpenseViewer(BuildContext context, ExpenseInDb expense) async {
  if (!context.mounted) return;

  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  final branchName = getIt<AuthCubit>().currentBranchName;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ExpenseViewerPage(expense: expense, branchName: branchName),
    ),
  );
}

/// Abre el visor cargando el gasto por id y manteniendo los estados de carga y
/// error dentro de la misma pantalla.
Future<void> showExpenseViewerFromId(BuildContext context, String expenseId) async {
  if (!context.mounted) return;

  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  final branchName = getIt<AuthCubit>().currentBranchName;
  final expensesRepository = context.read<ExpensesRepository>();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) {
        return FutureBuilder<ExpenseInDb?>(
          future: expensesRepository.getExpenseById(expenseId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return const _ExpenseViewerLoadingScaffold();
            }

            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return _ExpenseViewerErrorScaffold(
                message: asyncSnapshot.error?.toString() ?? 'No se encontró el gasto solicitado.',
              );
            }

            return ExpenseViewerPage(
              expense: asyncSnapshot.data!,
              branchName: branchName,
            );
          },
        );
      },
    ),
  );
}

/// Ficha de solo lectura con la información completa de un gasto.
///
/// Es un widget puro (no depende de `getIt`) para poder reutilizarlo y probarlo
/// de forma aislada.
class ExpenseViewerPage extends StatelessWidget {
  const ExpenseViewerPage({
    super.key,
    required this.expense,
    required this.branchName,
  });

  final ExpenseInDb expense;
  final String branchName;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(expense.type);
    final isOverdue = isExpenseOverdue(expense);
    final docNumber = expense.docNumber.trim().isEmpty ? 'S/N' : expense.docNumber;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detalle del Gasto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
            ),
            Text(
              _typeTitle(expense.type),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: AppThemeTokens.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusMd,
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            final padding = isCompact
                ? const EdgeInsets.fromLTRB(4, 6, 4, 16)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 20);

            return Center(
              child: SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ExpenseHeroCard(
                        expense: expense,
                        docNumber: docNumber,
                        accent: accent,
                        isOverdue: isOverdue,
                      ),
                      const SizedBox(height: 10),
                      _ExpenseAmountCard(expense: expense, accent: accent),
                      const SizedBox(height: 10),
                      _ExpenseDetailGrid(
                        expense: expense,
                        branchName: branchName,
                        isOverdue: isOverdue,
                      ),
                      const SizedBox(height: 10),
                      _ExpenseDescriptionCard(description: expense.description),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseHeroCard extends StatelessWidget {
  const _ExpenseHeroCard({
    required this.expense,
    required this.docNumber,
    required this.accent,
    required this.isOverdue,
  });

  final ExpenseInDb expense;
  final String docNumber;
  final Color accent;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppThemeTokens.borderRadiusMd,
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Icon(_iconFor(expense.type), color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeTitle(expense.type),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'N° $docNumber',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppStatusBadge(
                label: _typeBadge(expense.type),
                icon: _iconFor(expense.type),
                color: accent,
              ),
              ExpenseStatusBadge(status: expense.status),
              if (isOverdue) const ExpenseOverdueBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseAmountCard extends StatelessWidget {
  const _ExpenseAmountCard({
    required this.expense,
    required this.accent,
  });

  final ExpenseInDb expense;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monto del gasto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormatter.convertToMoneyLike(expense.amount),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: accent,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: accent.withValues(alpha: 0.20)),
            ),
            child: Icon(Icons.payments_rounded, color: accent, size: 23),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDetailGrid extends StatelessWidget {
  const _ExpenseDetailGrid({
    required this.expense,
    required this.branchName,
    required this.isOverdue,
  });

  final ExpenseInDb expense;
  final String branchName;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 2 : 1;
        const spacing = 10.0;
        final itemWidth = columns == 1 ? constraints.maxWidth : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _ExpenseDetailCard(
                  item: item,
                  isOverdue: item.label == 'Vencimiento' && isOverdue,
                ),
              ),
          ],
        );
      },
    );
  }

  List<_ExpenseDetailData> _items() {
    final supplierName = expense.supplierName.trim();
    final category = expense.category.trim();
    final createdByName = expense.createdBy.name.trim();
    final paidAt = expense.paidAt;

    return [
      if (expense.type == ExpenseType.supplier)
        _ExpenseDetailData(
          icon: Icons.business_rounded,
          label: 'Proveedor',
          value: supplierName.isEmpty ? '—' : supplierName,
        ),
      if (expense.type != ExpenseType.supplier || category.isNotEmpty)
        _ExpenseDetailData(
          icon: Icons.category_rounded,
          label: 'Categoría',
          value: category.isEmpty ? '—' : category,
        ),
      _ExpenseDetailData(
        icon: Icons.receipt_long_rounded,
        label: 'N° Documento',
        value: expense.docNumber.trim().isEmpty ? '—' : expense.docNumber,
      ),
      _ExpenseDetailData(
        icon: Icons.event_rounded,
        label: 'Fecha documento',
        value: DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expense.date)),
      ),
      _ExpenseDetailData(
        icon: Icons.schedule_rounded,
        label: 'Vencimiento',
        value: expense.expirationDate == null
            ? '—'
            : DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!)),
      ),
      _ExpenseDetailData(
        icon: Icons.history_rounded,
        label: 'Registrado el',
        value: DateTimeTool.formatddMMyyEs(expense.createdAt),
      ),
      _ExpenseDetailData(
        icon: Icons.person_outline_rounded,
        label: 'Elaborado por',
        value: createdByName.isEmpty ? '—' : createdByName,
      ),
      _ExpenseDetailData(
        icon: Icons.check_circle_outline_rounded,
        label: 'Pagado el',
        value: paidAt == null ? '—' : DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(paidAt)),
      ),
      _ExpenseDetailData(
        icon: Icons.store_mall_directory_rounded,
        label: 'Sucursal',
        value: branchName.trim().isEmpty ? '—' : branchName,
      ),
    ];
  }
}

class _ExpenseDetailCard extends StatelessWidget {
  const _ExpenseDetailCard({
    required this.item,
    required this.isOverdue,
  });

  final _ExpenseDetailData item;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final valueColor = isOverdue ? AppThemeTokens.danger : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppThemeTokens.borderRadiusSm,
              border: Border.all(color: AppThemeTokens.borderLight),
            ),
            child: Icon(item.icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDescriptionCard extends StatelessWidget {
  const _ExpenseDescriptionCard({required this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    final text = description?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, size: 17, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text.isEmpty ? 'Sin descripción' : text,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF334155),
              fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseViewerLoadingScaffold extends StatelessWidget {
  const _ExpenseViewerLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Gasto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ExpenseViewerErrorScaffold extends StatelessWidget {
  const _ExpenseViewerErrorScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Gasto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'No se pudo cargar el gasto',
                    subtitle: message,
                    accentColor: AppThemeTokens.danger,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpenseDetailData {
  const _ExpenseDetailData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

Color _accentFor(ExpenseType type) {
  switch (type) {
    case ExpenseType.operative:
      return const Color(0xFF16A34A);
    case ExpenseType.supplier:
      return const Color(0xFFEA580C);
    case ExpenseType.tax:
      return AppThemeTokens.purple;
  }
}

String _typeTitle(ExpenseType type) {
  switch (type) {
    case ExpenseType.operative:
      return 'Gasto Operativo';
    case ExpenseType.supplier:
      return 'Gasto de Proveedor';
    case ExpenseType.tax:
      return 'Gasto de Impuesto';
  }
}

String _typeBadge(ExpenseType type) {
  switch (type) {
    case ExpenseType.operative:
      return 'Operativo';
    case ExpenseType.supplier:
      return 'Proveedor';
    case ExpenseType.tax:
      return 'Impuesto';
  }
}

IconData _iconFor(ExpenseType type) {
  switch (type) {
    case ExpenseType.operative:
      return Icons.account_balance_wallet_rounded;
    case ExpenseType.supplier:
      return Icons.storefront_rounded;
    case ExpenseType.tax:
      return Icons.account_balance_rounded;
  }
}
