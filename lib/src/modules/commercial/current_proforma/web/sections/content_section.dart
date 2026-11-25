part of '../current_proforma_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<ReadProformaCubit, ReadProformaState>(
        builder: (context, state) {
          if (state is ReadProformaLoading || state is ReadProformaInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadProformaError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las cotizaciones',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context
                  .read<ReadProformaCubit>()
                  .loadPaginatedOrders(getIt<AuthCubit>().currentBranchId),
            );
          }

          final orders = (state as ReadProformaSuccess).orders;

          if (orders.isEmpty) {
            return Gate(
              filters: const [
                RolePermissionGateFilter(
                  permissions: [CommercialSubModules.createOrder],
                ),
              ],
              fallback: const AppEmptyState(
                icon: Icons.description_outlined,
                title: 'Sin cotizaciones',
                subtitle: 'No hay cotizaciones registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
              ),
              child: AppEmptyState(
                icon: Icons.description_outlined,
                title: 'Sin cotizaciones',
                subtitle: 'No hay cotizaciones registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
                actionLabel: 'Nueva Cotización',
                actionIcon: Icons.add_rounded,
                onAction: () => _openCreateProforma(context),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              final cubit = context.read<ReadProformaCubit>();
              return cubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
            },
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
                  order: currentOrder,
                  backgroundColor: tileColor,
                  onTap: () async {
                    await showProformaInvoiceCreatorDialog(context, currentOrder);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
