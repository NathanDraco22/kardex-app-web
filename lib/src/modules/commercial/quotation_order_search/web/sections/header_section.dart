part of '../quotation_order_search_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  ClientInDb? currentSelectedClient;
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();

    if (isSellerRole) {
      currentSelectedUser = userInDb;
    }

    return Card(
      key: ValueKey(readCubit.state),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryMenuButton(
                    onPressed: () {
                      readCubit.clearFilters(getIt<AuthCubit>().currentBranchId);
                      if (!isSellerRole) {
                        currentSelectedUser = null;
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar"),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("start_date_${readCubit.startDate.hashCode}"),
                      defaultDate: readCubit.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        readCubit.startDate = value;
                        setState(() {});
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("end_date_${readCubit.endDate.hashCode}"),
                      defaultDate: readCubit.endDate,
                      title: "Fecha Fin",
                      onSelected: (value) {
                        readCubit.endDate = value;
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SecondaryMenuButton(
                    onPressed: () async {
                      final client = await showClientSelectionDialog(context);
                      if (client == null) return;
                      readCubit.clientId = client.id;
                      currentSelectedClient = client;
                      setState(() {});
                    },
                    icon: const Icon(Icons.business),
                    label: currentSelectedClient == null
                        ? const Text("Seleccionar Cliente")
                        : Text(currentSelectedClient!.name),
                  ),
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 250,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        readCubit.userCreatorId = user?.id;
                        currentSelectedUser = user;
                        setState(() {});
                      },
                    ),
                  const SizedBox(width: 8),
                  if (readCubit.state is ReadQuotationOrderSearchSuccess) ...[
                    PrimaryMenuButton(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        final state = readCubit.state as ReadQuotationOrderSearchSuccess;

                        final template = OrdersByUserTemplate(
                          title: "Buscador de Cotizaciones/Órdenes",
                          userInfo: currentSelectedUser != null
                              ? UserInfo(id: currentSelectedUser!.id, name: currentSelectedUser!.username)
                              : null,
                          clientInfo: currentSelectedClient != null
                              ? ClientInfo(name: currentSelectedClient!.name, group: "")
                              : null,
                          startDate: readCubit.startDate,
                          endDate: readCubit.endDate,
                          count: state.totalCount,
                          total: state.totalAmount,
                          items: state.orders,
                        );

                        await PdfExportTool.export(
                          template,
                          fileName: "cotizaciones_ordenes.pdf",
                        );
                      },
                      label: const Text("Exportar"),
                      icon: const Icon(Icons.picture_as_pdf),
                    ),
                    const SizedBox(width: 8),
                  ],
                  PrimaryMenuButton(
                    onPressed: () {
                      readCubit.loadDocuments(getIt<AuthCubit>().currentBranchId);
                    },
                    label: const Text("Filtrar"),
                    icon: const Icon(Icons.filter_alt_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
