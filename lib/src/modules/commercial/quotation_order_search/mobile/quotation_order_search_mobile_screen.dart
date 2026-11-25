import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/quotation_order_search/cubit/read_quotation_order_search_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/orders_by_user_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
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

class QuotationOrderSearchMobileScreen extends StatelessWidget {
  const QuotationOrderSearchMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Cotizaciones/Órdenes'),
        actions: [
          BlocBuilder<ReadQuotationOrderSearchCubit, ReadQuotationOrderSearchState>(
            builder: (context, state) {
              final isLoading = state is ReadQuotationOrderSearchLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<ReadQuotationOrderSearchCubit>()
                        .loadDocuments(getIt<AuthCubit>().currentBranchId),
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
            onPressed: () => context.pushNamed(RouteNames.proforma),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cotización'),
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
    final state = context.watch<ReadQuotationOrderSearchCubit>().state;
    if (state is! ReadQuotationOrderSearchSuccess) {
      return const SizedBox.shrink();
    }

    final formattedTotal = NumberFormatter.convertToMoneyLike(state.totalAmount);
    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: 'Monto Total (${state.totalCount})',
            bigTitle: formattedTotal,
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
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final state = readCubit.state;

    return RefreshIndicator(
      onRefresh: () => readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
        children: [
          const _MobileFilters(),
          if (state is ReadQuotationOrderSearchLoading ||
              state is ReadQuotationOrderSearchLoadingMore)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const SizedBox(height: 10),
          if (state is ReadQuotationOrderSearchInitial ||
              (state is ReadQuotationOrderSearchLoading &&
                  state is! ReadQuotationOrderSearchLoadingMore))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state is ReadQuotationOrderSearchError)
            AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar los documentos',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId),
            )
          else if (state is ReadQuotationOrderSearchSuccess) ...[
            if (state.orders.isEmpty)
              Gate(
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
  ClientInDb? _selectedClient;
  UserInDb? _selectedUser;
  int _clearGeneration = 0;

  @override
  void initState() {
    super.initState();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole) {
      _selectedUser = userInDb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();

    if (isSellerRole && _selectedUser == null) {
      _selectedUser = userInDb;
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
                  child: DatePickerListTile(
                    key: ValueKey(
                      'm_start_${readCubit.startDate?.millisecondsSinceEpoch}_$_clearGeneration',
                    ),
                    defaultDate: readCubit.startDate,
                    title: 'Fecha Inicio',
                    onSelected: (value) {
                      readCubit.startDate = value;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DatePickerListTile(
                    key: ValueKey(
                      'm_end_${readCubit.endDate?.millisecondsSinceEpoch}_$_clearGeneration',
                    ),
                    defaultDate: readCubit.endDate,
                    title: 'Fecha Fin',
                    onSelected: (value) {
                      readCubit.endDate = value;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            SecondaryMenuButton(
              onPressed: () async {
                final client = await showClientSelectionDialog(context);
                if (client == null) return;
                readCubit.clientId = client.id;
                setState(() => _selectedClient = client);
              },
              icon: const Icon(Icons.business),
              label: Text(_selectedClient?.name ?? 'Seleccionar Cliente'),
            ),
            if (!isSellerRole)
              UserDropdownSelector(
                width: double.infinity,
                selectedUser: _selectedUser,
                onChanged: (user) {
                  readCubit.userCreatorId = user?.id;
                  setState(() => _selectedUser = user);
                },
              ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedClient = null;
                      _selectedUser = isSellerRole ? userInDb : null;
                      _clearGeneration++;
                    });
                    readCubit.clearFilters(getIt<AuthCubit>().currentBranchId);
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpiar'),
                ),
                if (readCubit.state is ReadQuotationOrderSearchSuccess)
                  SecondaryMenuButton(
                    onPressed: () async {
                      final state = readCubit.state as ReadQuotationOrderSearchSuccess;
                      final template = OrdersByUserTemplate(
                        title: 'Buscador de Cotizaciones/Órdenes',
                        userInfo: _selectedUser != null
                            ? UserInfo(id: _selectedUser!.id, name: _selectedUser!.username)
                            : null,
                        clientInfo: _selectedClient != null
                            ? ClientInfo(name: _selectedClient!.name, group: '')
                            : null,
                        startDate: readCubit.startDate,
                        endDate: readCubit.endDate,
                        count: state.totalCount,
                        total: state.totalAmount,
                        items: state.orders,
                      );

                      await PdfExportTool.export(
                        template,
                        fileName: 'cotizaciones_ordenes.pdf',
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Exportar'),
                  ),
                PrimaryMenuButton(
                  onPressed: () => readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId),
                  icon: const Icon(Icons.filter_alt_rounded, size: 18),
                  label: const Text('Filtrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
