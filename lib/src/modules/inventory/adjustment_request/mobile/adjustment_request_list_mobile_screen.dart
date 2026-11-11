import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/read_adjustment_requests_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_list_tile.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_totals_bar.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestListMobileScreen extends StatelessWidget {
  const AdjustmentRequestListMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Ajuste'),
        actions: [
          BlocBuilder<ReadAdjustmentRequestsCubit, ReadAdjustmentRequestsState>(
            builder: (context, state) {
              final isRefreshing = state is ReadAdjustmentRequestsSuccess && state.isRefreshing;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isRefreshing ? null : () => context.read<ReadAdjustmentRequestsCubit>().refresh(),
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(RouteNames.adjustmentRequestCreate),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Solicitud'),
        ),
      ),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAdjustmentRequestsCubit, ReadAdjustmentRequestsState>(
      builder: (context, state) {
        final success = state is ReadAdjustmentRequestsSuccess ? state : null;

        return RefreshIndicator(
          onRefresh: () => context.read<ReadAdjustmentRequestsCubit>().refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.maxScrollExtent > 0 && metrics.pixels >= metrics.maxScrollExtent - 200) {
                context.read<ReadAdjustmentRequestsCubit>().loadMore();
              }
              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
              children: [
                const _MobileFilters(),
                if (success?.isRefreshing == true || success?.isLoadingMore == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                const SizedBox(height: 10),
                if (state is ReadAdjustmentRequestsInitial || state is ReadAdjustmentRequestsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is ReadAdjustmentRequestsError)
                  AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'No se pudieron cargar las solicitudes',
                    subtitle: state.message,
                    accentColor: AppThemeTokens.danger,
                    actionLabel: 'Reintentar',
                    actionIcon: Icons.refresh_rounded,
                    onAction: () => context.read<ReadAdjustmentRequestsCubit>().refresh(),
                  )
                else if (success != null) ...[
                  if (success.items.isEmpty)
                    AppEmptyState(
                      icon: Icons.fact_check_outlined,
                      title: 'Sin solicitudes',
                      subtitle: 'No hay solicitudes para los filtros seleccionados.',
                      accentColor: AppThemeTokens.indigo,
                      actionLabel: 'Nueva Solicitud',
                      actionIcon: Icons.add_rounded,
                      onAction: () => context.pushNamed(RouteNames.adjustmentRequestCreate),
                    )
                  else ...[
                    for (final request in success.items) ...[
                      AdjustmentRequestCardTile(
                        request: request,
                        onTap: () => context.pushNamed(
                          RouteNames.adjustmentRequestDetail,
                          pathParameters: {'requestId': request.id},
                          extra: request,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (success.hasMore)
                      Center(
                        child: TextButton.icon(
                          onPressed: success.isLoadingMore
                              ? null
                              : () => context.read<ReadAdjustmentRequestsCubit>().loadMore(),
                          icon: const Icon(Icons.expand_more_rounded, size: 18),
                          label: Text(success.isLoadingMore ? 'Cargando más...' : 'Cargar más registros'),
                        ),
                      ),
                    if (success.loadMoreError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: AppThemeTokens.danger),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                success.loadMoreError!,
                                style: const TextStyle(fontSize: 12, color: AppThemeTokens.danger),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<ReadAdjustmentRequestsCubit>().loadMore(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    AdjustmentRequestTotalsBar(
                      itemCount: success.items.length,
                      itemCountLabel: 'Solicitudes',
                      entryTotal: success.items.fold<int>(0, (sum, item) => sum + item.entryTotal),
                      exitTotal: success.items.fold<int>(0, (sum, item) => sum + item.exitTotal),
                      compact: true,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MobileFilters extends StatefulWidget {
  const _MobileFilters();

  @override
  State<_MobileFilters> createState() => _MobileFiltersState();
}

class _MobileFiltersState extends State<_MobileFilters> {
  late final TextEditingController _docNumberController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'all';
  UserInDb? _selectedUser;
  bool _expanded = true;
  int _clearGeneration = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadAdjustmentRequestsCubit>();
    _startDate = cubit.startDate;
    _endDate = cubit.endDate;
    _status = cubit.status ?? 'all';
    _docNumberController = TextEditingController(text: cubit.docNumber ?? '');
    final (isSeller, sellerUser) = RoleTools.isSeller();
    if (isSeller) _selectedUser = sellerUser;
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final docNumber = _docNumberController.text.trim();
    final (isSeller, sellerUser) = RoleTools.isSeller();
    context.read<ReadAdjustmentRequestsCubit>().applyFilters(
      startDate: _startDate,
      endDate: _endDate,
      status: _status == 'all' ? null : _status,
      createdBy: isSeller ? sellerUser?.id : _selectedUser?.id,
      docNumber: docNumber.isEmpty ? null : docNumber,
    );
  }

  void _clearFilters() {
    final cubit = context.read<ReadAdjustmentRequestsCubit>();
    final today = DateTimeTool.getTodayMidnight();
    final (isSeller, sellerUser) = RoleTools.isSeller();
    _docNumberController.clear();
    setState(() {
      _startDate = today.subtract(const Duration(days: 29));
      _endDate = today;
      _status = 'all';
      _selectedUser = isSeller ? sellerUser : null;
      _clearGeneration++;
    });
    cubit.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final (isSeller, _) = RoleTools.isSeller();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: AppThemeTokens.borderRadiusSm,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 18, color: AppThemeTokens.indigo),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Filtros',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey('end_start_${_startDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                      defaultDate: _startDate,
                      title: 'Fecha inicio',
                      onSelected: (value) => setState(() => _startDate = value),
                    ),
                  ),
                ],
              ),
              DatePickerListTile(
                key: ValueKey('end_end_${_endDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                defaultDate: _endDate,
                title: 'Fecha fin',
                onSelected: (value) => setState(() => _endDate = value),
              ),
              const SizedBox(height: 6),
              if (!isSeller)
                UserDropdownSelector(
                  isExpanded: true,
                  selectedUser: _selectedUser,
                  onChanged: (user) => setState(() => _selectedUser = user),
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('m_status_${_status}_$_clearGeneration'),
                initialValue: _status,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Todos')),
                  DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'approved', child: Text('Aprobada')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelada')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'all'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _docNumberController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'No. solicitud',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SecondaryMenuButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                      label: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PrimaryMenuButton(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.filter_alt_rounded, size: 18),
                      label: const Text('Filtrar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
