import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/read_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/web/devolution_processor_screen.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
// Requerido en lite donde widgets.dart no re-exporta DevolutionStatusChip.
// ignore: unnecessary_import
import 'package:kardex_app_front/widgets/elements/devolution_status_chip.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class CurrentDevolutionsMobileScreen extends StatelessWidget {
  const CurrentDevolutionsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devoluciones en Proceso'),
        actions: [
          BlocBuilder<ReadDevolutionCubit, ReadDevolutionState>(
            builder: (context, state) {
              final isLoading = state is ReadDevolutionLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context.read<ReadDevolutionCubit>().loadAllDevolutions(),
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Gate(
        filters: const [
          RolePermissionGateFilter(
            permissions: [CommercialSubModules.createInvoice],
          ),
        ],
        child: Visibility(
          visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
          child: FloatingActionButton.extended(
            onPressed: () => context.pushNamed(RouteNames.devolutions),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Devolución'),
          ),
        ),
      ),
      bottomNavigationBar: const _MobileBottomAppBar(),
      body: const _MobileBody(),
    );
  }
}

class _MobileBottomAppBar extends StatelessWidget {
  const _MobileBottomAppBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadDevolutionCubit>().state;
    if (state is! ReadDevolutionSuccess) {
      return const SizedBox.shrink();
    }

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: 'Monto Total (${state.devolutions.length})',
            bigTitle: NumberFormatter.convertToMoneyLike(state.totalAmount),
          ),
        ],
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDevolutionCubit>();
    final state = readCubit.state;

    return RefreshIndicator(
      onRefresh: () => readCubit.loadAllDevolutions(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
        children: [
          const _MobileFilters(),
          if (state is ReadDevolutionLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const SizedBox(height: 10),
          if (state is ReadDevolutionInitial || state is ReadDevolutionLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state is ReadDevolutionError)
            AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las devoluciones',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => readCubit.loadAllDevolutions(),
            )
          else if (state is ReadDevolutionSuccess) ...[
            if (state.devolutions.isEmpty)
              Gate(
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
              )
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var index = 0; index < state.devolutions.length; index++) ...[
                      Builder(
                        builder: (context) {
                          final currentDevolution = state.devolutions[index];
                          Color tileColor = RowColorTool.getRowColor(index);
                          if (state.updatedDevolutionIds.contains(currentDevolution.id)) {
                            tileColor = Colors.blue.shade100;
                          } else if (state.newDevolutionIds.contains(currentDevolution.id)) {
                            tileColor = Colors.yellow.shade200;
                          }

                          return Ink(
                            color: tileColor,
                            child: InkWell(
                              onTap: () => showDevolutionProcessorDialog(
                                context,
                                currentDevolution,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 6,
                                  children: [
                                    Row(
                                      children: [
                                        DevolutionStatusChip(
                                          status: currentDevolution.status,
                                          width: 96,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            currentDevolution.clientInfo.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          NumberFormatter.convertToMoneyLike(
                                            currentDevolution.total,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          DateTimeTool.formatddMMyy(
                                            currentDevolution.createdAt,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '# ${currentDevolution.docNumber}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (currentDevolution.originalInvoiceDocNumber.isNotEmpty) ...[
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Fact: ${currentDevolution.originalInvoiceDocNumber}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (index < state.devolutions.length - 1)
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MobileFilters extends StatefulWidget {
  const _MobileFilters();

  @override
  State<_MobileFilters> createState() => _MobileFiltersState();
}

class _MobileFiltersState extends State<_MobileFilters> {
  late final TextEditingController _searchController;
  ClientInDb? _selectedClient;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadDevolutionCubit>();
    _searchController = TextEditingController(text: cubit.searchKeyword);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDevolutionCubit>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DevolutionStatus?>(
                    initialValue: readCubit.status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem<DevolutionStatus?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      DropdownMenuItem<DevolutionStatus?>(
                        value: DevolutionStatus.open,
                        child: Text('Abierta'),
                      ),
                      DropdownMenuItem<DevolutionStatus?>(
                        value: DevolutionStatus.confirmed,
                        child: Text('Confirmada'),
                      ),
                      DropdownMenuItem<DevolutionStatus?>(
                        value: DevolutionStatus.applied,
                        child: Text('Aplicada'),
                      ),
                      DropdownMenuItem<DevolutionStatus?>(
                        value: DevolutionStatus.cancelled,
                        child: Text('Cancelada'),
                      ),
                    ],
                    onChanged: (value) {
                      readCubit.applyFilters(
                        status: value,
                        clearStatus: value == null,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _selectedClient = null);
                    readCubit.clearFilters();
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            SecondaryMenuButton(
              onPressed: () async {
                final client = await showClientSelectionDialog(context);
                if (client == null || !context.mounted) return;
                setState(() => _selectedClient = client);
                await readCubit.applyFilters(clientId: client.id);
              },
              icon: const Icon(Icons.business),
              label: Text(_selectedClient?.name ?? 'Seleccionar cliente'),
            ),
            TextField(
              controller: _searchController,
              onChanged: readCubit.searchDevolution,
              decoration: InputDecoration(
                labelText: 'Buscar folio o cliente',
                isDense: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar búsqueda',
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          readCubit.searchDevolution('');
                          setState(() {});
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
