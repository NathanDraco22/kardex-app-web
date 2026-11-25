part of '../current_devolutions_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<ReadDevolutionCubit, ReadDevolutionState>(
        builder: (context, state) {
          if (state is ReadDevolutionLoading || state is ReadDevolutionInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadDevolutionError) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las devoluciones',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context.read<ReadDevolutionCubit>().loadAllDevolutions(),
            );
          }

          final success = state as ReadDevolutionSuccess;
          final devolutions = success.devolutions;

          if (devolutions.isEmpty) {
            return Gate(
              filters: const [
                RolePermissionGateFilter(
                  permissions: [CommercialSubModules.createInvoice],
                ),
              ],
              fallback: const AppEmptyState(
                icon: Icons.assignment_return_outlined,
                title: 'Sin devoluciones',
                subtitle: 'No hay devoluciones registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
              ),
              child: AppEmptyState(
                icon: Icons.assignment_return_outlined,
                title: 'Sin devoluciones',
                subtitle: 'No hay devoluciones registradas para los filtros seleccionados.',
                accentColor: AppThemeTokens.indigo,
                actionLabel: 'Nueva Devolución',
                actionIcon: Icons.add_rounded,
                onAction: () => context.pushNamed(RouteNames.devolutions),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ReadDevolutionCubit>().loadAllDevolutions(),
            child: ListView.separated(
              itemCount: devolutions.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE2E8F0),
              ),
              itemBuilder: (context, index) {
                final currentDevolution = devolutions[index];
                Color tileColor = RowColorTool.getRowColor(index);
                if (success.updatedDevolutionIds.contains(currentDevolution.id)) {
                  tileColor = Colors.blue.shade100;
                } else if (success.newDevolutionIds.contains(currentDevolution.id)) {
                  tileColor = Colors.yellow.shade200;
                }

                return _DevolutionListTile(
                  devolution: currentDevolution,
                  tileColor: tileColor,
                  onTap: () => showDevolutionProcessorDialog(context, currentDevolution),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DevolutionListTile extends StatelessWidget {
  const _DevolutionListTile({
    required this.devolution,
    required this.tileColor,
    required this.onTap,
  });

  final DevolutionInDb devolution;
  final Color tileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: tileColor,
      child: ListTile(
        onTap: onTap,
        leading: DevolutionStatusChip(
          status: devolution.status,
          width: 100,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                devolution.clientInfo.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              NumberFormatter.convertToMoneyLike(devolution.total),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        subtitle: Wrap(
          spacing: 12,
          runSpacing: 2,
          children: [
            Text(
              DateTimeTool.formatddMMyy(devolution.createdAt),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '# ${devolution.docNumber}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (devolution.originalInvoiceDocNumber.isNotEmpty)
              Text(
                'Factura: ${devolution.originalInvoiceDocNumber}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
          ],
        ),
      ),
    );
  }
}
