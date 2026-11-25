part of '../daily_product_in_orders_screen_web.dart';

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
    final readCubit = context.watch<ReadDailyProductInOrdersCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole && currentSelectedUser == null) {
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey('start_date_${readCubit.startDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                      defaultDate: readCubit.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        readCubit.startDate = value;
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey('end_date_${readCubit.endDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                      defaultDate: readCubit.endDate,
                      title: "Fecha Fin",
                      onSelected: (value) {
                        readCubit.endDate = value;
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
                spacing: 12,
                runSpacing: 8,
                children: [
                  ClientDropdownSelector(
                    width: 280,
                    selectedClient: currentSelectedClient,
                    selectedClientId: readCubit.clientId,
                    onChanged: (client) {
                      currentSelectedClient = client;
                      readCubit.clientId = client?.id;
                      setState(() {});
                    },
                  ),
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 280,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        currentSelectedUser = user;
                        readCubit.userCreatorId = user?.id;
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (readCubit.state is ReadDailyProductInOrdersSuccess) ...[
                        PrimaryMenuButton(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          label: const Text("Exportar"),
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () async {
                            final option = await showExportOptionsDialog(context);
                            if (option == null || !context.mounted) return;

                            final state = readCubit.state as ReadDailyProductInOrdersSuccess;

                            if (option == ExportOption.csv) {
                              await CsvExportTool.exportProductSalesToCSV(
                                products: state.productTotals,
                                fileName: "productos_en_ordenes_compra",
                              );
                            } else if (option == ExportOption.pdf) {
                              final template = ProductByUserTemplate(
                                title: "Productos en Órdenes de Compra",
                                branchName: getIt<AuthCubit>().currentBranchName,
                                userInfo: currentSelectedUser != null
                                    ? UserInfo(id: currentSelectedUser!.id, name: currentSelectedUser!.username)
                                    : null,
                                clientLabel: currentSelectedClient?.name,
                                startDate: readCubit.startDate,
                                endDate: readCubit.endDate,
                                count: state.productTotals.length,
                                total: state.totalAmount,
                                items: state.productTotals,
                              );

                              await PdfExportTool.export(
                                template,
                                fileName: "productos_en_ordenes_compra.pdf",
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      PrimaryMenuButton(
                        onPressed: () {
                          readCubit.loadDailyProductInOrders(
                            branchId: getIt<AuthCubit>().currentBranchId,
                            startDate: readCubit.startDate,
                            endDate: readCubit.endDate,
                            clientId: readCubit.clientId,
                            clearClient: readCubit.clientId == null,
                            userCreatorId: readCubit.userCreatorId,
                            clearUserCreator: !isSellerRole && readCubit.userCreatorId == null,
                          );
                        },
                        label: const Text("Filtrar"),
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                    ],
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
                    label: const Text("Limpiar"),
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
