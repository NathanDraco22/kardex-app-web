part of '../daily_client_invoices_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadDailyClientInvoicesCubit>();
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final user = await showActiveUserSelectionDialog(context);
                          if (user == null) return;
                          readCubit.userCreatorId = user.id;
                          currentSelectedUser = user;
                          setState(() {});
                        },
                        child: currentSelectedUser == null
                            ? const Text("Seleccionar Usuario")
                            : Text(currentSelectedUser!.username),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      readCubit.loadPaidInvoices();
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
