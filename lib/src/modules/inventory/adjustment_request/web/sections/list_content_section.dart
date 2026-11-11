part of '../adjustment_request_list_web_screen.dart';

class _ListContentSection extends StatefulWidget {
  const _ListContentSection();

  @override
  State<_ListContentSection> createState() => _ListContentSectionState();
}

class _ListContentSectionState extends State<_ListContentSection> {
  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.maxScrollExtent <= 0) return false;
    if (metrics.pixels >= metrics.maxScrollExtent - 220) {
      context.read<ReadAdjustmentRequestsCubit>().loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadAdjustmentRequestsCubit, ReadAdjustmentRequestsState>(
      builder: (context, state) {
        if (state is ReadAdjustmentRequestsInitial || state is ReadAdjustmentRequestsLoading) {
          return const Card(
            margin: EdgeInsets.zero,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReadAdjustmentRequestsError) {
          return Card(
            margin: EdgeInsets.zero,
            child: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las solicitudes',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context.read<ReadAdjustmentRequestsCubit>().refresh(),
            ),
          );
        }

        final success = state as ReadAdjustmentRequestsSuccess;

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (success.isRefreshing || success.isLoadingMore) const LinearProgressIndicator(minHeight: 2),
              const AdjustmentRequestTableHeader(),
              Expanded(
                child: success.items.isEmpty
                    ? AppEmptyState(
                        icon: Icons.fact_check_outlined,
                        title: 'Sin solicitudes para los filtros',
                        subtitle: 'Ajusta el rango de fechas o crea una nueva solicitud de ajuste.',
                        accentColor: AppThemeTokens.indigo,
                        actionLabel: 'Nueva Solicitud',
                        actionIcon: Icons.add_rounded,
                        onAction: () => context.pushNamed(RouteNames.adjustmentRequestCreate),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: ListView.builder(
                          itemCount: success.items.length,
                          itemBuilder: (context, index) {
                            final request = success.items[index];
                            return AdjustmentRequestTableRow(
                              request: request,
                              showDivider: index < success.items.length - 1,
                              onTap: () => context.pushNamed(
                                RouteNames.adjustmentRequestDetail,
                                pathParameters: {'requestId': request.id},
                                extra: request,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              if (success.hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),
        );
      },
    );
  }
}
