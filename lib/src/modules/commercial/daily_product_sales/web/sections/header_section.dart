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
                        readCubit.loadDailyProductSales(startDate: value);
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  TextButton.icon(
                    onPressed: () {
                      readCubit.clearFilters();
                      currentSelectedUser = null;
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar Filtros"),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final user = await showActiveUserSelectionDialog(context);
                    if (user == null) return;
                    readCubit.loadDailyProductSales(userCreatorId: user.id);
                    currentSelectedUser = user;
                    setState(() {});
                  },
                  child: const Text("Seleccionar Usuario"),
                ),
                const Spacer(),
                if (readCubit.state is ReadDailyProductSalesSuccess)
                  FilledButton.icon(
                    onPressed: () async {
                      final products = (readCubit.state as ReadDailyProductSalesSuccess).productTotals;
                      await CsvExportTool.exportProductSalesToCSV(
                        products: products,
                        fileName: "ventas_diarias",
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Exportar CSV"),
                  ),
              ],
            ),

            if (currentSelectedUser != null)
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
