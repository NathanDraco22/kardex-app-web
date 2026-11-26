import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/expenses/accounts_payable/cubit/accounts_payable_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/accounts_payable/view/supplier_payable_detail_screen.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class AccountsPayableScreen extends StatelessWidget {
  const AccountsPayableScreen({
    super.key,
    this.branchId,
  });

  final String? branchId;

  @override
  Widget build(BuildContext context) {
    final expensesRepo = context.read<ExpensesRepository>();

    return BlocProvider(
      create: (_) => AccountsPayableCubit(expensesRepo, branchId: branchId)..load(),
      child: AccountsPayableView(branchId: branchId),
    );
  }
}

class AccountsPayableView extends StatefulWidget {
  const AccountsPayableView({
    super.key,
    this.branchId,
  });

  final String? branchId;

  @override
  State<AccountsPayableView> createState() => _AccountsPayableViewState();
}

class _AccountsPayableViewState extends State<AccountsPayableView> {
  static const double _desktopBreakpoint = 900;
  static const Color _accentColor = Color(0xFFD97706);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyOverdue = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openSupplierDetail(SupplierPayableSummary supplier) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SupplierPayableDetailScreen(
          supplier: supplier,
          branchId: widget.branchId,
        ),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      context.read<AccountsPayableCubit>().refresh();
    }
  }

  List<SupplierPayableSummary> _filterSuppliers(AccountsPayableSummary summary) {
    final query = _searchQuery.trim().toLowerCase();
    return summary.suppliers.where((s) {
      if (_onlyOverdue && s.overdueAmount <= 0 && s.overdueCount <= 0) {
        return false;
      }
      if (query.isNotEmpty && !s.supplierName.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsPayableCubit, AccountsPayableState>(
      builder: (context, state) {
        final loaded = state is AccountsPayableLoaded ? state : null;
        final isRefreshing = loaded?.isRefreshing ?? false;
        final visibleSuppliers = loaded == null ? const <SupplierPayableSummary>[] : _filterSuppliers(loaded.summary);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
            final horizontalPadding = isDesktop ? (constraints.maxWidth >= 1280 ? 32.0 : 16.0) : 8.0;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Cuentas por Pagar'),
                actions: [
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: isRefreshing ? null : () => context.read<AccountsPayableCubit>().refresh(),
                    icon: isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, size: 21),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              bottomNavigationBar: !isDesktop && loaded != null && loaded.summary.totalPending > 0
                  ? _AccountsPayableBottomBar(summary: loaded.summary)
                  : null,
              body: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: RefreshIndicator(
                      color: _accentColor,
                      onRefresh: () => context.read<AccountsPayableCubit>().refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (loaded != null) ...[
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                              sliver: SliverToBoxAdapter(
                                child: _PayableHeaderCard(
                                  summary: loaded.summary,
                                  searchController: _searchController,
                                  searchQuery: _searchQuery,
                                  onlyOverdue: _onlyOverdue,
                                  onSearchChanged: (value) => setState(() => _searchQuery = value),
                                  onToggleOverdue: (value) => setState(() => _onlyOverdue = value),
                                ),
                              ),
                            ),
                            if (loaded.refreshError != null)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppThemeTokens.danger.withValues(alpha: 0.08),
                                      borderRadius: AppThemeTokens.borderRadiusMd,
                                      border: Border.all(
                                        color: AppThemeTokens.danger.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 18,
                                          color: AppThemeTokens.danger,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'No se pudo actualizar el resumen. Se muestran los datos anteriores.',
                                            style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: isRefreshing
                                              ? null
                                              : () => context.read<AccountsPayableCubit>().refresh(),
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          ..._buildContent(
                            context: context,
                            state: state,
                            loaded: loaded,
                            visibleSuppliers: visibleSuppliers,
                            isDesktop: isDesktop,
                            horizontalPadding: horizontalPadding,
                          ),
                          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildContent({
    required BuildContext context,
    required AccountsPayableState state,
    required AccountsPayableLoaded? loaded,
    required List<SupplierPayableSummary> visibleSuppliers,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    if (state is AccountsPayableInitial || state is AccountsPayableLoading) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: isDesktop
                ? AppSkeletonLoader.listTile(count: 6, padding: EdgeInsets.zero)
                : AppSkeletonLoader.cards(count: 4, padding: EdgeInsets.zero),
          ),
        ),
      ];
    }

    if (state is AccountsPayableError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'No se pudieron cargar las cuentas por pagar',
                subtitle: state.message,
                accentColor: AppThemeTokens.danger,
                actionLabel: 'Reintentar',
                actionIcon: Icons.refresh_rounded,
                onAction: () => context.read<AccountsPayableCubit>().load(),
              ),
            ),
          ),
        ),
      ];
    }

    if (visibleSuppliers.isEmpty) {
      final hasFilters = _searchQuery.trim().isNotEmpty || _onlyOverdue;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: AppEmptyState(
                icon: hasFilters ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
                title: hasFilters ? 'Sin resultados' : '¡Al día con proveedores!',
                subtitle: hasFilters
                    ? 'Ningún proveedor coincide con los filtros actuales.'
                    : 'No tienes facturas ni gastos pendientes por pagar en esta sucursal.',
                accentColor: hasFilters ? _accentColor : AppThemeTokens.success,
                actionLabel: hasFilters ? 'Limpiar filtros' : 'Actualizar',
                actionIcon: hasFilters ? Icons.filter_alt_off_rounded : Icons.refresh_rounded,
                onAction: hasFilters
                    ? () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _onlyOverdue = false;
                        });
                      }
                    : () => context.read<AccountsPayableCubit>().refresh(),
              ),
            ),
          ),
        ),
      ];
    }

    if (isDesktop) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusLg,
                border: Border.all(color: AppThemeTokens.borderLight),
                boxShadow: AppThemeTokens.subtleCardShadow(),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const _PayableTableHeader(),
                  for (var i = 0; i < visibleSuppliers.length; i++)
                    _SupplierPayableTableRow(
                      supplier: visibleSuppliers[i],
                      showDivider: i < visibleSuppliers.length - 1,
                      onTap: () => _openSupplierDetail(visibleSuppliers[i]),
                    ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
        sliver: SliverList.separated(
          itemCount: visibleSuppliers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) => _SupplierPayableMobileCard(
            supplier: visibleSuppliers[index],
            onTap: () => _openSupplierDetail(visibleSuppliers[index]),
          ),
        ),
      ),
    ];
  }
}

class _PayableHeaderCard extends StatelessWidget {
  const _PayableHeaderCard({
    required this.summary,
    required this.searchController,
    required this.searchQuery,
    required this.onlyOverdue,
    required this.onSearchChanged,
    required this.onToggleOverdue,
  });

  final AccountsPayableSummary summary;
  final TextEditingController searchController;
  final String searchQuery;
  final bool onlyOverdue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onToggleOverdue;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 680;
              final tiles = [
                _KpiBox(
                  label: 'Total por Pagar',
                  value: NumberFormatter.convertToMoneyLike(summary.totalPending),
                  color: const Color(0xFFD97706),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _KpiBox(
                  label: 'Total Vencido',
                  value: NumberFormatter.convertToMoneyLike(summary.totalOverdue),
                  color: summary.totalOverdue > 0 ? AppThemeTokens.danger : const Color(0xFF64748B),
                  icon: Icons.warning_amber_rounded,
                ),
                _KpiBox(
                  label: 'Proveedores',
                  value: summary.suppliersCount.toString(),
                  color: const Color(0xFF2563EB),
                  icon: Icons.storefront_rounded,
                ),
                _KpiBox(
                  label: 'Documentos',
                  value: summary.documentsCount.toString(),
                  color: const Color(0xFF334155),
                  icon: Icons.receipt_long_rounded,
                ),
              ];

              if (isCompact) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.3,
                  children: tiles,
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    Expanded(child: tiles[i]),
                    if (i < tiles.length - 1) const SizedBox(width: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 240, maxWidth: 380),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar proveedor...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
                    ),
                  ),
                ),
              ),
              FilterChip(
                selected: onlyOverdue,
                onSelected: onToggleOverdue,
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: onlyOverdue ? Colors.white : AppThemeTokens.danger,
                ),
                label: const Text('Solo con vencidos'),
                selectedColor: AppThemeTokens.danger,
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: onlyOverdue ? Colors.white : const Color(0xFF334155),
                ),
                checkmarkColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  const _KpiBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
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

class _PayableTableHeader extends StatelessWidget {
  const _PayableTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('PROVEEDOR', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('DOCS PENDIENTES', style: _headerStyle),
          ),
          Expanded(
            flex: 3,
            child: Text('PRÓXIMO VENCIMIENTO', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('VENCIDO', textAlign: TextAlign.right, style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('SALDO POR PAGAR', textAlign: TextAlign.right, style: _headerStyle),
          ),
          SizedBox(width: 28),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Color(0xFF64748B),
    letterSpacing: 0.4,
  );
}

class _SupplierPayableTableRow extends StatelessWidget {
  const _SupplierPayableTableRow({
    required this.supplier,
    required this.showDivider,
    required this.onTap,
  });

  final SupplierPayableSummary supplier;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasOverdue = supplier.overdueAmount > 0;
    final oldestDue = supplier.oldestDueDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(supplier.oldestDueDate!);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.supplierName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Total facturado: ${NumberFormatter.convertToMoneyLike(supplier.totalAmount)}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${supplier.pendingCount}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    if (supplier.overdueCount > 0)
                      AppStatusBadge(
                        label: '${supplier.overdueCount} venc.',
                        variant: AppBadgeVariant.danger,
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: oldestDue == null
                    ? const Text('Sin vencimiento', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateTimeTool.formatddMMyyEs(oldestDue),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: hasOverdue ? FontWeight.w700 : FontWeight.w500,
                              color: hasOverdue ? AppThemeTokens.danger : const Color(0xFF334155),
                            ),
                          ),
                          ExpenseDueRelativeLabel(expirationDate: supplier.oldestDueDate),
                        ],
                      ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  NumberFormatter.convertToMoneyLike(supplier.overdueAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasOverdue ? AppThemeTokens.danger : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  NumberFormatter.convertToMoneyLike(supplier.pendingAmount),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(
                width: 28,
                child: Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierPayableMobileCard extends StatelessWidget {
  const _SupplierPayableMobileCard({
    required this.supplier,
    required this.onTap,
  });

  final SupplierPayableSummary supplier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasOverdue = supplier.overdueAmount > 0;
    final oldestDue = supplier.oldestDueDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(supplier.oldestDueDate!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(
          color: hasOverdue ? AppThemeTokens.danger.withValues(alpha: 0.35) : AppThemeTokens.borderLight,
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
                  children: [
                    Expanded(
                      child: Text(
                        supplier.supplierName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      NumberFormatter.convertToMoneyLike(supplier.pendingAmount),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${supplier.pendingCount} docs pendientes',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (hasOverdue)
                      AppStatusBadge(
                        label: 'Vencido: ${NumberFormatter.convertToMoneyLike(supplier.overdueAmount)}',
                        variant: AppBadgeVariant.danger,
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      ),
                  ],
                ),
                if (oldestDue != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Venc. más antiguo: ${DateTimeTool.formatddMMyyEs(oldestDue)} • ',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                      Expanded(
                        child: ExpenseDueRelativeLabel(
                          expirationDate: supplier.oldestDueDate,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountsPayableBottomBar extends StatelessWidget {
  const _AccountsPayableBottomBar({required this.summary});

  final AccountsPayableSummary summary;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Por Pagar', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(
                  NumberFormatter.convertToMoneyLike(summary.totalPending),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Vencido', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(
                  NumberFormatter.convertToMoneyLike(summary.totalOverdue),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: summary.totalOverdue > 0 ? AppThemeTokens.danger : const Color(0xFF64748B),
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
