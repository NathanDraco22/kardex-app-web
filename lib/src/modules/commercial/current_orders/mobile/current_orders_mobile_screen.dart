import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
// Requerido en lite donde widgets.dart no re-exporta CustomOrderListTile.
// ignore: unnecessary_import
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class CurrentOrdersMobileScreen extends StatelessWidget {
  const CurrentOrdersMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
        actions: [
          BlocBuilder<ReadOrderCubit, ReadOrderState>(
            builder: (context, state) {
              final isLoading = state is ReadOrderLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context.read<ReadOrderCubit>().loadPaginatedOrders(),
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Gate(
        filters: const [
          RolePermissionGateFilter(
            permissions: [CommercialSubModules.createOrder],
          ),
        ],
        child: Visibility(
          visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
          child: FloatingActionButton.extended(
            onPressed: () => context.pushNamed(RouteNames.saleOrder),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Orden'),
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
    final state = context.watch<ReadOrderCubit>().state;
    if (state is! ReadOrderSuccess) {
      return const SizedBox.shrink();
    }

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: 'Monto Total (${state.orders.length})',
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
    final readCubit = context.watch<ReadOrderCubit>();
    final state = readCubit.state;

    return RefreshIndicator(
      onRefresh: () => readCubit.loadPaginatedOrders(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
        children: [
          const _MobileFilters(),
          if (state is ReadOrderLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const SizedBox(height: 10),
          if (state is ReadOrderInitial || state is ReadOrderLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state is ReadOrderError)
            AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las órdenes',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => readCubit.loadPaginatedOrders(),
            )
          else if (state is ReadOrderSuccess) ...[
            if (state.orders.isEmpty)
              Gate(
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
              )
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var index = 0; index < state.orders.length; index++) ...[
                      Builder(
                        builder: (context) {
                          final currentOrder = state.orders[index];
                          Color tileColor = RowColorTool.getRowColor(index);
                          if (state.updatedOrderIds.contains(currentOrder.id)) {
                            tileColor = Colors.blue.shade100;
                          } else if (state.newOrderIds.contains(currentOrder.id)) {
                            tileColor = Colors.yellow.shade200;
                          }

                          return CustomOrderListTile(
                            order: currentOrder,
                            backgroundColor: tileColor,
                            onTap: () => showOrderInvoiceCreatorDialog(
                              context,
                              currentOrder,
                            ),
                          );
                        },
                      ),
                      if (index < state.orders.length - 1)
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
  UserInDb? _selectedUser;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadOrderCubit>();
    _searchController = TextEditingController(text: cubit.searchKeyword);
    final (isSeller, currentUser) = RoleTools.isSeller();
    if (isSeller) {
      _selectedUser = currentUser;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadOrderCubit>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    if (isSeller && _selectedUser == null) {
      _selectedUser = currentUser;
    }

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
                  child: DropdownButtonFormField<OrderStatus?>(
                    initialValue: readCubit.status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem<OrderStatus?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      DropdownMenuItem<OrderStatus?>(
                        value: OrderStatus.open,
                        child: Text('Abierta'),
                      ),
                      DropdownMenuItem<OrderStatus?>(
                        value: OrderStatus.completed,
                        child: Text('Completada'),
                      ),
                      DropdownMenuItem<OrderStatus?>(
                        value: OrderStatus.cancelled,
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
                    setState(() {
                      _selectedClient = null;
                      _selectedUser = isSeller ? currentUser : null;
                    });
                    readCubit.clearFilterParams();
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
            if (!isSeller)
              UserDropdownSelector(
                width: double.infinity,
                selectedUser: _selectedUser,
                onChanged: (user) {
                  setState(() => _selectedUser = user);
                  readCubit.applyFilters(
                    createdBy: user?.id,
                    clearCreatedBy: user == null,
                  );
                },
              ),
            TextField(
              controller: _searchController,
              onChanged: readCubit.searchOrder,
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
                          readCubit.searchOrder('');
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
