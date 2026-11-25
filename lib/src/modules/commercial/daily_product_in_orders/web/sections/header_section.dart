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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: DatePickerListTile(
                key: ValueKey('start_date_${readCubit.startDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                defaultDate: readCubit.startDate,
                title: "Fecha Inicio",
                onSelected: (value) {
                  readCubit.loadDailyProductInOrders(
                    branchId: getIt<AuthCubit>().currentBranchId,
                    startDate: value,
                  );
                },
              ),
            ),
            SizedBox(
              width: 210,
              child: DatePickerListTile(
                key: ValueKey('end_date_${readCubit.endDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                defaultDate: readCubit.endDate,
                title: "Fecha Fin",
                onSelected: (value) {
                  readCubit.loadDailyProductInOrders(
                    branchId: getIt<AuthCubit>().currentBranchId,
                    endDate: value,
                  );
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SecondaryMenuButton(
                  onPressed: () async {
                    final client = await showClientSelectionDialog(context);
                    if (client == null || !context.mounted) return;
                    setState(() => currentSelectedClient = client);
                    await readCubit.loadDailyProductInOrders(
                      branchId: getIt<AuthCubit>().currentBranchId,
                      clientId: client.id,
                    );
                  },
                  icon: const Icon(Icons.business),
                  label: Text(currentSelectedClient?.name ?? 'Seleccionar Cliente'),
                ),
                if (currentSelectedClient != null)
                  IconButton(
                    tooltip: 'Quitar cliente',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() => currentSelectedClient = null);
                      readCubit.loadDailyProductInOrders(
                        branchId: getIt<AuthCubit>().currentBranchId,
                        clearClient: true,
                      );
                    },
                  ),
              ],
            ),
            if (!isSellerRole)
              UserDropdownSelector(
                width: 240,
                selectedUser: currentSelectedUser,
                onChanged: (user) {
                  setState(() => currentSelectedUser = user);
                  readCubit.loadDailyProductInOrders(
                    branchId: getIt<AuthCubit>().currentBranchId,
                    userCreatorId: user?.id,
                    clearUserCreator: user == null,
                  );
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
              label: const Text("Limpiar"),
            ),
            if (readCubit.state is ReadDailyProductInOrdersSuccess)
              PrimaryMenuButton(
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
          ],
        ),
      ),
    );
  }
}
