part of '../daily_invoices_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadDailyAnonInvoicesCubit>();
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
                        readCubit.loadDailyPaidAnonInvoices(startDate: value);
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
            TextButton(
              onPressed: () async {
                final user = await showActiveUserSelectionDialog(context);
                if (user == null) return;
                readCubit.loadDailyPaidAnonInvoices(userCreatorId: user.id);
                currentSelectedUser = user;
                setState(() {});
              },
              child: const Text("Seleccionar Usuario"),
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
