part of '../paid_invoices_web_screen.dart';

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
            const Flexible(fit: FlexFit.tight, child: Row()),
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Cliente",
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        CustomAutocompleteTextfield<ClientInDb>(
                          onClose: (value) => readCubit.clientId = value.id,
                          key: ValueKey(readCubit.clientId),
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
                  ),
                  const SizedBox(width: 4), // Espaciado
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: Row(
                      children: [
                        Flexible(
                          child: DatePickerListTile(
                            key: ValueKey(readCubit.startDate),
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
                            key: ValueKey(readCubit.endDate),
                            defaultDate: readCubit.endDate,
                            title: "Fecha Fin",
                            onSelected: (value) {
                              readCubit.endDate = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  readCubit.loadPaidInvoices();
                                },
                                label: const Text("Filtrar"),
                                icon: const Icon(Icons.filter_alt_rounded),
                              ),
                              const SizedBox(width: 12),
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
                        ),
                      ],
                    ),
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
