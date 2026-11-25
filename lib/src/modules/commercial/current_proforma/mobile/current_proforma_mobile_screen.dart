import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class CurrentProformaMobileScreen extends StatelessWidget {
  const CurrentProformaMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: [
          BlocBuilder<ReadProformaCubit, ReadProformaState>(
            builder: (context, state) {
              final isLoading = state is ReadProformaLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<ReadProformaCubit>()
                        .loadPaginatedOrders(getIt<AuthCubit>().currentBranchId),
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
            onPressed: () => _openCreateProforma(context),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cotización'),
          ),
        ),
      ),
      body: const _MobileBody(),
    );
  }
}

Future<void> _openCreateProforma(BuildContext context) async {
  await context.pushNamed(RouteNames.proforma);
  if (!context.mounted) return;
  await context.read<ReadProformaCubit>().loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadProformaCubit, ReadProformaState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context
              .read<ReadProformaCubit>()
              .loadPaginatedOrders(getIt<AuthCubit>().currentBranchId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
            children: [
              const _MobileFilters(),
              if (state is ReadProformaLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 10),
              if (state is ReadProformaInitial || state is ReadProformaLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is ReadProformaError)
                AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'No se pudieron cargar las cotizaciones',
                  subtitle: state.message,
                  accentColor: AppThemeTokens.danger,
                  actionLabel: 'Reintentar',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () => context
                      .read<ReadProformaCubit>()
                      .loadPaginatedOrders(getIt<AuthCubit>().currentBranchId),
                )
              else if (state is ReadProformaSuccess) ...[
                if (state.orders.isEmpty) ...[
                  Gate(
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
                  ),
                ] else
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var index = 0; index < state.orders.length; index++) ...[
                          CustomOrderListTile(
                            order: state.orders[index],
                            backgroundColor: RowColorTool.getRowColor(index),
                            onTap: () async {
                              await showProformaInvoiceCreatorDialog(
                                context,
                                state.orders[index],
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
  ClientInDb? _selectedClient;
  UserInDb? _selectedUser;

  @override
  void initState() {
    super.initState();
    final (isSeller, currentUser) = RoleTools.isSeller();
    if (isSeller && currentUser != null) {
      _selectedUser = currentUser;
    }
  }

  void _reload(BuildContext context) {
    final (isSeller, currentUser) = RoleTools.isSeller();
    final cubit = context.read<ReadProformaCubit>();
    cubit.setFilterParams(
      clientId: _selectedClient?.id,
      createdBy: isSeller ? currentUser?.id : _selectedUser?.id,
    );
    cubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
  }

  @override
  Widget build(BuildContext context) {
    final (isSeller, currentUser) = RoleTools.isSeller();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            SecondaryMenuButton(
              onPressed: () async {
                final client = await showClientSelectionDialog(context);
                if (client == null || !context.mounted) return;
                setState(() => _selectedClient = client);
                _reload(context);
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
                  _reload(context);
                },
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedClient = null;
                    _selectedUser = isSeller ? currentUser : null;
                  });
                  final cubit = context.read<ReadProformaCubit>();
                  cubit.clearFilterParams();
                  cubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Limpiar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
