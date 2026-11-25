part of '../current_orders_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<ReadOrderCubit, ReadOrderState>(
        builder: (context, state) {
          if (state is ReadOrderLoading || state is ReadOrderInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadOrderError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las órdenes',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context.read<ReadOrderCubit>().loadPaginatedOrders(),
            );
          }

          final success = state as ReadOrderSuccess;
          final orders = success.orders;

          if (orders.isEmpty) {
            return Gate(
              filters: const [
                RolePermissionGateFilter(
                  permissions: [CommercialSubModules.createOrder],
                ),
              ],
              fallback: const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Sin órdenes de compra',
                subtitle: 'No hay órdenes registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
              ),
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Sin órdenes de compra',
                subtitle: 'No hay órdenes registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
                actionLabel: 'Nueva Orden',
                actionIcon: Icons.add_rounded,
                onAction: () => context.pushNamed(RouteNames.saleOrder),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ReadOrderCubit>().loadPaginatedOrders(),
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
                if (success.updatedOrderIds.contains(currentOrder.id)) {
                  tileColor = Colors.blue.shade100;
                } else if (success.newOrderIds.contains(currentOrder.id)) {
                  tileColor = Colors.yellow.shade200;
                }

                return CustomOrderListTile(
                  backgroundColor: tileColor,
                  order: currentOrder,
                  onTap: () => showOrderInvoiceCreatorDialog(context, currentOrder),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
