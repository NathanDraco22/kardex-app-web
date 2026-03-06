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
                        readCubit.loadDailyProductInOrders(startDate: value);
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
                    readCubit.loadDailyProductInOrders(userCreatorId: user.id);
                    currentSelectedUser = user;
                    setState(() {});
                  },
                  child: const Text("Seleccionar Usuario"),
                ),
                const Spacer(),
                if (readCubit.state is ReadDailyProductInOrdersSuccess)
                  FilledButton.icon(
                    onPressed: () async {
                      final products = (readCubit.state as ReadDailyProductInOrdersSuccess).productTotals;
                      await CsvExportTool.exportProductSalesToCSV(
                        products: products,
                        fileName: "productos_en_pedidos",
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
