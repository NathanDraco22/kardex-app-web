part of '../daily_product_in_orders_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyProductInOrdersCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole) {
      currentSelectedUser = userInDb;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 70,
              width: 300,
              child: Row(
                children: [
                  Flexible(
                    child: DatePickerButton(
                      key: ValueKey(readCubit.startDate),
                      defaultDate: readCubit.startDate,
                      title: "Fecha",
                      onSelected: (value) {
                        readCubit.loadDailyProductInOrders(
                          branchId: getIt<AuthCubit>().currentBranchId,
                          startDate: value,
                        );
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  TextButton.icon(
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
                children: [
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 250,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        currentSelectedUser = user;
                        readCubit.loadDailyProductInOrders(
                          branchId: getIt<AuthCubit>().currentBranchId,
                          userCreatorId: user?.id,
                        );
                        setState(() {});
                      },
                    ),
                  const Spacer(),
                  if (readCubit.state is ReadDailyProductInOrdersSuccess)
                    FilledButton.icon(
                      onPressed: () async {
                        // Importar export_options_dialog en daily_product_in_orders_screen_web
                        final option = await showExportOptionsDialog(context);
                        if (option == null) return;

                        final state = readCubit.state as ReadDailyProductInOrdersSuccess;

                        if (option == ExportOption.csv) {
                          await CsvExportTool.exportProductSalesToCSV(
                            products: state.productTotals,
                            fileName: "productos_en_pedidos",
                          );
                        } else if (option == ExportOption.pdf) {
                          final template = ProductByUserTemplate(
                            title: "Productos en Pedidos (Diario)",
                            branchName: getIt<AuthCubit>().currentBranchName,
                            userInfo: currentSelectedUser != null
                                ? UserInfo(id: currentSelectedUser!.id, name: currentSelectedUser!.username)
                                : null,
                            startDate: readCubit.startDate,
                            endDate: null,
                            count: state.productTotals.length,
                            total: state.totalAmount,
                            items: state.productTotals,
                          );

                          await PdfExportTool.export(
                            template,
                            fileName: "productos_en_pedidos_diario.pdf",
                          );
                        }
                      },
                      icon: const Icon(Icons.import_export),
                      label: const Text("Exportar"),
                    ),
                ],
              ),
            ),

            if (currentSelectedUser != null && !isSellerRole)
              Text(
                currentSelectedUser!.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
