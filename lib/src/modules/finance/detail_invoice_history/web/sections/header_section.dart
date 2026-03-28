part of '../invoice_history_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceHistoryCubit>();
    return Card(
      key: ValueKey(readCubit.params),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DatePickerButton(
                      defaultDate: DateTime.now().endOfDay(),
                      title: "Fecha Limite",
                      onSelected: (value) {
                        readCubit.params.endDate = value.endOfDay();
                        readCubit.loadInvoicesHistory();
                      },
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final invoiceRepo = context.read<InvoicesRepository>();
                        showSimpleSearchDialog<InvoiceInDb>(
                          context,
                          title: "Buscar #Factura",
                          searchFuture: (value) {
                            return invoiceRepo.getInvoiceByDocNumber(value);
                          },
                          onResult: (value) {
                            showInvoiceInspector(context, value);
                          },
                        );
                      },
                      label: const Text("Buscar #Factura"),
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600, minWidth: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cliente",
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 6),

                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: CustomAutocompleteTextfield<ClientInDb>(
                                  onClose: (value) {
                                    readCubit.params.clientId = value.id;
                                    readCubit.loadInvoicesHistory();
                                  },
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
                                            close(client);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () {
                        readCubit.setDefaultParams();
                      },
                      label: const Text("Limpiar"),
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
