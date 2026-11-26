import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/dialogs/register_expense_payment_dialog.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/expense_viewer_page.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class SupplierPayableDetailScreen extends StatelessWidget {
  const SupplierPayableDetailScreen({
    super.key,
    required this.supplier,
    this.branchId,
  });

  final SupplierPayableSummary supplier;
  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final expensesRepo = context.read<ExpensesRepository>();

    return BlocProvider(
      create: (_) => WriteExpenseCubit(expensesRepo),
      child: _SupplierPayableDetailBody(
        supplier: supplier,
        branchId: branchId,
      ),
    );
  }
}

class _SupplierPayableDetailBody extends StatefulWidget {
  const _SupplierPayableDetailBody({
    required this.supplier,
    this.branchId,
  });

  final SupplierPayableSummary supplier;
  final String? branchId;

  @override
  State<_SupplierPayableDetailBody> createState() => _SupplierPayableDetailBodyState();
}

class _SupplierPayableDetailBodyState extends State<_SupplierPayableDetailBody> {
  static const Color _accentColor = Color(0xFFD97706);

  bool _loading = true;
  String? _error;
  List<ExpenseInDb> _items = const [];
  bool _hasChanges = false;

  String get _resolvedBranchId {
    if (widget.branchId != null && widget.branchId!.isNotEmpty) {
      return widget.branchId!;
    }
    if (getIt.isRegistered<AuthCubit>()) {
      return getIt<AuthCubit>().currentBranchId;
    }
    return '';
  }

  String get _resolvedBranchName {
    if (getIt.isRegistered<AuthCubit>()) {
      return getIt<AuthCubit>().currentBranchName;
    }
    return 'Sucursal';
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<ExpensesRepository>();
      final params = ExpenseQueryParams()
        ..type = ExpenseType.supplier.name
        ..onlyPending = true
        ..limit = 200;

      if (widget.supplier.supplierId.isNotEmpty) {
        params.supplierId = widget.supplier.supplierId;
      }
      if (_resolvedBranchId.isNotEmpty) {
        params.branchId = _resolvedBranchId;
      }

      final fetched = await repo.getAllExpenses(params);
      final filtered = fetched.where((e) {
        if (e.isDeleted || e.remainingAmount <= 0) return false;
        if (widget.supplier.supplierId.isNotEmpty) {
          return e.supplierId == widget.supplier.supplierId;
        }
        return e.supplierName.trim() == widget.supplier.supplierName.trim();
      }).toList()
        ..sort(_compareByDueUrgency);

      if (!mounted) return;
      setState(() {
        _items = filtered;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  static int _compareByDueUrgency(ExpenseInDb a, ExpenseInDb b) {
    final aDue = a.expirationDate;
    final bDue = b.expirationDate;
    if (aDue == null && bDue == null) return a.createdAt.compareTo(b.createdAt);
    if (aDue == null) return 1;
    if (bDue == null) return -1;
    return aDue.compareTo(bDue);
  }

  Future<void> _registerPayment(ExpenseInDb expense) async {
    final updated = await showRegisterExpensePaymentDialog(
      context,
      expense: expense,
    );
    if (!mounted || updated == null) return;

    _hasChanges = true;
    ExpenseActions.showSnackBar(
      context,
      updated.status == ExpenseStatus.paid ? 'Factura liquidada correctamente' : 'Abono registrado correctamente',
    );

    setState(() {
      if (updated.status == ExpenseStatus.paid || updated.remainingAmount <= 0) {
        _items = _items.where((item) => item.id != updated.id).toList(growable: false);
      } else {
        _items = _items
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
      }
    });
  }

  Future<void> _openViewer(ExpenseInDb expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseViewerPage(
          expense: expense,
          branchName: _resolvedBranchName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _items.fold<int>(0, (sum, e) => sum + e.amount);
    final totalPaid = _items.fold<int>(0, (sum, e) => sum + e.effectiveAmountPaid);
    final totalPending = _items.fold<int>(0, (sum, e) => sum + e.remainingAmount);
    final totalOverdue = _items
        .where((e) => isExpenseOverdue(e))
        .fold<int>(0, (sum, e) => sum + e.remainingAmount);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.supplier.supplierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Text(
                'Documentos pendientes por pagar',
                style: TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              onPressed: _loading ? null : _loadDocuments,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: _buildBody(
                totalAmount: totalAmount,
                totalPaid: totalPaid,
                totalPending: totalPending,
                totalOverdue: totalOverdue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required int totalAmount,
    required int totalPaid,
    required int totalPending,
    required int totalOverdue,
  }) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppSkeletonLoader.cards(count: 4, padding: EdgeInsets.zero),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'No se pudieron cargar las facturas',
            subtitle: _error!,
            accentColor: AppThemeTokens.danger,
            actionLabel: 'Reintentar',
            actionIcon: Icons.refresh_rounded,
            onAction: _loadDocuments,
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'Sin saldo pendiente',
            subtitle: 'Este proveedor ya no tiene facturas o gastos pendientes por pagar.',
            accentColor: AppThemeTokens.success,
            actionLabel: 'Volver',
            actionIcon: Icons.arrow_back_rounded,
            onAction: () => Navigator.of(context).pop(_hasChanges),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _accentColor,
      onRefresh: _loadDocuments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _SupplierDetailKpiHeader(
            totalAmount: totalAmount,
            totalPaid: totalPaid,
            totalPending: totalPending,
            totalOverdue: totalOverdue,
            documentsCount: _items.length,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _items.length; i++) ...[
            _SupplierPayableDocCard(
              expense: _items[i],
              onTap: () => _openViewer(_items[i]),
              onPay: () => _registerPayment(_items[i]),
            ),
            if (i < _items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SupplierDetailKpiHeader extends StatelessWidget {
  const _SupplierDetailKpiHeader({
    required this.totalAmount,
    required this.totalPaid,
    required this.totalPending,
    required this.totalOverdue,
    required this.documentsCount,
  });

  final int totalAmount;
  final int totalPaid;
  final int totalPending;
  final int totalOverdue;
  final int documentsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          _KpiStat(
            label: 'Saldo por pagar ($documentsCount)',
            value: NumberFormatter.convertToMoneyLike(totalPending),
            color: const Color(0xFFD97706),
          ),
          _KpiStat(
            label: 'Vencido',
            value: NumberFormatter.convertToMoneyLike(totalOverdue),
            color: totalOverdue > 0 ? AppThemeTokens.danger : const Color(0xFF64748B),
          ),
          _KpiStat(
            label: 'Abonado',
            value: NumberFormatter.convertToMoneyLike(totalPaid),
            color: AppThemeTokens.success,
          ),
          _KpiStat(
            label: 'Total facturado',
            value: NumberFormatter.convertToMoneyLike(totalAmount),
            color: const Color(0xFF334155),
          ),
        ],
      ),
    );
  }
}

class _KpiStat extends StatelessWidget {
  const _KpiStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierPayableDocCard extends StatelessWidget {
  const _SupplierPayableDocCard({
    required this.expense,
    required this.onTap,
    required this.onPay,
  });

  final ExpenseInDb expense;
  final VoidCallback onTap;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final isOverdue = isExpenseOverdue(expense);
    final doc = expense.docNumber.trim().isEmpty ? 'Sin N° documento' : 'Doc. ${expense.docNumber}';
    final dueDate = expense.expirationDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!);
    final progress = expense.amount > 0
        ? (expense.effectiveAmountPaid / expense.amount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(
          color: isOverdue ? AppThemeTokens.danger.withValues(alpha: 0.35) : AppThemeTokens.borderLight,
        ),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                doc,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              ExpenseStatusBadge(status: expense.status, compact: true),
                              if (isOverdue) const ExpenseOverdueBadge(compact: true),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Fecha: ${DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expense.date))}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (dueDate != null)
                                Text(
                                  'Vence: ${DateTimeTool.formatddMMyyEs(dueDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                    color: isOverdue ? AppThemeTokens.danger : const Color(0xFF475569),
                                  ),
                                ),
                            ],
                          ),
                          if (dueDate != null) ...[
                            const SizedBox(height: 3),
                            ExpenseDueRelativeLabel(
                              expirationDate: expense.expirationDate,
                              status: expense.status,
                              fontSize: 11.5,
                            ),
                          ],
                          if (expense.description != null && expense.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              expense.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormatter.convertToMoneyLike(expense.remainingAmount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isOverdue ? AppThemeTokens.danger : const Color(0xFFD97706),
                          ),
                        ),
                        const Text(
                          'Saldo pendiente',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: onPay,
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('Abonar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppThemeTokens.borderRadiusMd,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppThemeTokens.success),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${NumberFormatter.convertToMoneyLike(expense.amount)}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    Text(
                      'Abonado: ${NumberFormatter.convertToMoneyLike(expense.effectiveAmountPaid)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
