part of '../daily_product_sales_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;
  ClientInDb? currentSelectedClient;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyProductSalesCubit>();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("start_date_${readCubit.startDate.hashCode}"),
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
                      key: ValueKey("end_date_${readCubit.endDate.hashCode}"),
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
                    allowNoClient: true,
                    selectedClient: currentSelectedClient,
                    selectedClientId: readCubit.clientId,
                    onChanged: (client) {
                      currentSelectedClient = client;
                      setState(() {});
                    },
                    onIdChanged: (clientId) {
                      readCubit.clientId = clientId;
                      setState(() {});
                    },
                  ),
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 280,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        readCubit.userCreatorId = user?.id;
                        currentSelectedUser = user;
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
                      if (readCubit.state is ReadDailyProductSalesSuccess) ...[
                        PrimaryMenuButton(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          label: const Text("Exportar"),
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () async {
                            final option = await showExportOptionsDialog(context);
                            if (option == null) return;

                            final state = readCubit.state as ReadDailyProductSalesSuccess;

                            if (option == ExportOption.csv) {
                              await CsvExportTool.exportProductSalesToCSV(
                                products: state.productTotals,
                                fileName: "ventas_por_producto",
                              );
                            } else if (option == ExportOption.pdf) {
                              final clientLabel = readCubit.clientId == kSaleClientId
                                  ? "Sin cliente (Venta libre)"
                                  : currentSelectedClient?.name;

                              final template = ProductByUserTemplate(
                                title: "Ventas por Producto",
                                branchName: getIt<AuthCubit>().currentBranchName,
                                userInfo: currentSelectedUser != null
                                    ? UserInfo(id: currentSelectedUser!.id, name: currentSelectedUser!.username)
                                    : null,
                                clientLabel: clientLabel,
                                startDate: readCubit.startDate,
                                endDate: readCubit.endDate,
                                count: state.productTotals.length,
                                total: state.totalAmount,
                                items: state.productTotals,
                              );

                              await PdfExportTool.export(
                                template,
                                fileName: "ventas_por_producto.pdf",
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      PrimaryMenuButton(
                        onPressed: () {
                          readCubit.loadDailyProductSales(
                            branchId: getIt<AuthCubit>().currentBranchId,
                          );
                        },
                        label: const Text("Filtrar"),
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                    ],
                  ),
                  SecondaryMenuButton(
                    onPressed: () {
                      readCubit.clearFilters(getIt<AuthCubit>().currentBranchId);
                      if (!isSellerRole) {
                        currentSelectedUser = null;
                      }
                      currentSelectedClient = null;
                      setState(() {});
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
