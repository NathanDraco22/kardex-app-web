part of '../invoice_history_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  ClientInDb? currentSelectedClient;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceHistoryCubit>();
    return Card(
      key: ValueKey(readCubit.params),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        readCubit.loadInvoicesHistory(getIt<AuthCubit>().currentBranchId);
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
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClientDropdownSelector(
                      width: 280,
                      selectedClient: currentSelectedClient,
                      onChanged: (client) {
                        currentSelectedClient = client;
                        readCubit.params.clientId = client?.id;
                        readCubit.loadInvoicesHistory(getIt<AuthCubit>().currentBranchId);
                        setState(() {});
                      },
                    ),
                    TextButton.icon(
                      onPressed: () {
                        currentSelectedClient = null;
                        readCubit.setDefaultParams(getIt<AuthCubit>().currentBranchId);
                        setState(() {});
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

