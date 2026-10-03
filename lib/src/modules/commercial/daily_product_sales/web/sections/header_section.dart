part of '../daily_product_sales_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

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
                        readCubit.loadDailyProductSales(branchId: getIt<AuthCubit>().currentBranchId, startDate: value);
                      },
                    ),
                  ),
                  const VerticalDivider(),
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
                children: [
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 250,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        currentSelectedUser = user;
                        readCubit.loadDailyProductSales(
                          branchId: getIt<AuthCubit>().currentBranchId,
                          userCreatorId: user?.id,
                        );
                        setState(() {});
                      },
                    ),
                  const Spacer(),
                  if (readCubit.state is ReadDailyProductSalesSuccess)
                    PrimaryMenuButton(
                      label: const Text("Exportar"),
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () async {
                        final option = await showExportOptionsDialog(context);
                        if (option == null) return;

                        final state = readCubit.state as ReadDailyProductSalesSuccess;

                        if (option == ExportOption.csv) {
                          await CsvExportTool.exportProductSalesToCSV(
                            products: state.productTotals,
                            fileName: "ventas_diarias_productos",
                          );
                        } else if (option == ExportOption.pdf) {
                          final template = ProductByUserTemplate(
                            title: "Ventas Diarias (Por Productos)",
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
                            fileName: "ventas_diarias_productos.pdf",
                          );
                        }
                      },
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
