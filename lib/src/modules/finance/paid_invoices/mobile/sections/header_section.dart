part of '../paid_invoices_mobile_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadPaidInvoicesCubit>();
    return Card(
      key: ValueKey(readCubit.state),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {
                    readCubit.clearFilters();
                    setState(() {});
                    readCubit.loadPaidInvoices();
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Cliente",
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                CustomAutocompleteTextfield<ClientInDb>(
                  key: ValueKey(readCubit.clientId),
                  onClose: (value) => readCubit.clientId = value.id,
                  titleBuilder: (value) => value.name,
                  onSearch: (value) async {
                    final repo = context.read<ClientsRepository>();
                    try {
                      final res = await repo.searchClientByKeyword(value);
                      return res;
                    } catch (e) {
                      return [];
                    }
                  },
                  suggestionBuilder: (value, close) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final client = value[index];
                        return ListTile(
                          title: Text(client.name),
                          onTap: () {
                            readCubit.clientId = client.id;
                            close(client);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            Row(
              children: [
                Flexible(
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
                Flexible(
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

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    readCubit.loadPaidInvoices();
                  },
                  label: const Text("Filtrar"),
                  icon: const Icon(Icons.filter_alt_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
