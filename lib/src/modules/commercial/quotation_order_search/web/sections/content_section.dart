part of '../quotation_order_search_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final state = readCubit.state;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (state is ReadQuotationOrderSearchLoading ||
              state is ReadQuotationOrderSearchLoadingMore)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state is ReadQuotationOrderSearchInitial ||
                    (state is ReadQuotationOrderSearchLoading &&
                        state is! ReadQuotationOrderSearchLoadingMore)) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReadQuotationOrderSearchError) {
                  return AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'No se pudieron cargar los documentos',
                    subtitle: state.message,
                    accentColor: AppThemeTokens.danger,
                    actionLabel: 'Reintentar',
                    actionIcon: Icons.refresh_rounded,
                    onAction: () => readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId),
                  );
                }

                if (state is! ReadQuotationOrderSearchSuccess) {
                  return const SizedBox.shrink();
                }

                final orders = state.orders;

                if (orders.isEmpty) {
                  return Gate(
                    filters: const [
                      RolePermissionGateFilter(
                        permissions: [CommercialSubModules.createOrder],
                      ),
                    ],
                    fallback: const AppEmptyState(
                      icon: Icons.manage_search_rounded,
                      title: 'Sin cotizaciones ni órdenes',
                      subtitle: 'No hay cotizaciones u órdenes para los filtros seleccionados.',
                      accentColor: AppThemeTokens.indigo,
                    ),
                    child: AppEmptyState(
                      icon: Icons.manage_search_rounded,
                      title: 'Sin cotizaciones ni órdenes',
                      subtitle: 'No hay cotizaciones u órdenes para los filtros seleccionados.',
                      accentColor: AppThemeTokens.indigo,
                      actionLabel: 'Nueva Cotización',
                      actionIcon: Icons.add_rounded,
                      onAction: () => context.pushNamed(RouteNames.proforma),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId),
                  child: ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    itemBuilder: (context, index) {
                      final currentOrder = orders[index];
                      Color tileColor = RowColorTool.getRowColor(index);
                      if (state.updatedOrderIds.contains(currentOrder.id)) {
                        tileColor = Colors.blue.shade100;
                      } else if (state.newOrderIds.contains(currentOrder.id)) {
                        tileColor = Colors.yellow.shade200;
                      }

                      return CustomOrderListTile(
                        backgroundColor: tileColor,
                        order: currentOrder,
                        onTap: () async {
                          final OrderInDb? result;
                          if (currentOrder.status == OrderStatus.draft) {
                            result = await showProformaInvoiceCreatorDialog(
                              context,
                              currentOrder,
                            );
                          } else {
                            result = await showOrderInvoiceCreatorDialog(
                              context,
                              currentOrder,
                            );
                          }
                          if (!context.mounted) return;
                          if (result == null) return;
                          readCubit.updateOrderInCache(result);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
