part of '../quotation_order_search_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  ClientInDb? currentSelectedClient;
  UserInDb? currentSelectedUser;
  int _clearGeneration = 0;

  @override
  void initState() {
    super.initState();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole) {
      currentSelectedUser = userInDb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();

    if (isSellerRole && currentSelectedUser == null) {
      currentSelectedUser = userInDb;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 210,
                        child: DatePickerListTile(
                          key: ValueKey(
                            'start_date_${readCubit.startDate?.millisecondsSinceEpoch}_$_clearGeneration',
                          ),
                          defaultDate: readCubit.startDate,
                          title: 'Fecha Inicio',
                          onSelected: (value) {
                            readCubit.startDate = value;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: DatePickerListTile(
                          key: ValueKey(
                            'end_date_${readCubit.endDate?.millisecondsSinceEpoch}_$_clearGeneration',
                          ),
                          defaultDate: readCubit.endDate,
                          title: 'Fecha Fin',
                          onSelected: (value) {
                            readCubit.endDate = value;
                            setState(() {});
                          },
                        ),
                      ),
                      SecondaryMenuButton(
                        onPressed: () async {
                          final client = await showClientSelectionDialog(context);
                          if (client == null) return;
                          readCubit.clientId = client.id;
                          setState(() {
                            currentSelectedClient = client;
                          });
                        },
                        icon: const Icon(Icons.business),
                        label: Text(currentSelectedClient?.name ?? 'Seleccionar Cliente'),
                      ),
                      if (!isSellerRole)
                        UserDropdownSelector(
                          width: 240,
                          selectedUser: currentSelectedUser,
                          onChanged: (user) {
                            readCubit.userCreatorId = user?.id;
                            setState(() {
                              currentSelectedUser = user;
                            });
                          },
                        ),
                      SecondaryMenuButton(
                        onPressed: () {
                          setState(() {
                            currentSelectedClient = null;
                            currentSelectedUser = isSellerRole ? userInDb : null;
                            _clearGeneration++;
                          });
                          readCubit.clearFilters(getIt<AuthCubit>().currentBranchId);
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                      ),
                      PrimaryMenuButton(
                        onPressed: () {
                          readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId);
                        },
                        label: const Text('Filtrar'),
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                      if (readCubit.state is ReadQuotationOrderSearchSuccess)
                        PrimaryMenuButton(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          onPressed: () async {
                            final state = readCubit.state as ReadQuotationOrderSearchSuccess;

                            final template = OrdersByUserTemplate(
                              title: 'Cotizaciones',
                              userInfo: currentSelectedUser != null
                                  ? UserInfo(
                                      id: currentSelectedUser!.id,
                                      name: currentSelectedUser!.username,
                                    )
                                  : null,
                              clientInfo: currentSelectedClient != null
                                  ? ClientInfo(name: currentSelectedClient!.name, group: '')
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
                          label: const Text('Exportar'),
                          icon: const Icon(Icons.picture_as_pdf),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Gate(
                  filters: const [
                    RolePermissionGateFilter(
                      permissions: [CommercialSubModules.createOrder],
                    ),
                  ],
                  child: FilledButton.icon(
                    onPressed: () => context.pushNamed(RouteNames.proforma),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nueva Cotización'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
