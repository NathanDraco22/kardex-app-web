part of '../pending_invoice_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = PendingInvoiceMediator.of(context);
    final viewController = mediator.notifier!;
    return Card(
      key: ValueKey(viewController.selectedClient ?? "null"),
      child: BlocBuilder<ReadPendingInvoiceCubit, ReadInvoiceState>(
        builder: (context, state) {
          if (state is ReadInvoiceInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.grey),
                  Text(
                    "Elige un cliente",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is ReadInvoiceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadInvoiceError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadInvoiceSuccess;

          final invoices = state.invoices;
          final devolutions = state.devolutions;

          viewController.devolutions = devolutions;

          if (invoices.isEmpty) {
            return const Center(
              child: Text(
                "No hay facturas pendientes",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              const SizedBox(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final devolutions = state.devolutions;
                      final total = devolutions.fold<int>(0, (previousValue, element) => previousValue + element.total);
                      return AlertDialog(
                        title: const Text("Devoluciones"),
                        actions: [
                          Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                NumberFormatter.convertToMoneyLike(total),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        content: SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: devolutions.length,
                            itemBuilder: (context, index) {
                              final currentDevolutions = devolutions[index];
                              return ListTile(
                                title: Text("#${currentDevolutions.docNumber}"),
                                onTap: () {
                                  showDevolutionViewerDialog(context, currentDevolutions);
                                },
                                subtitle: Text(
                                  DateTimeTool.formatddMMyy(currentDevolutions.createdAt),
                                ),
                                trailing: Text(
                                  NumberFormatter.convertToMoneyLike(currentDevolutions.total),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: Icon(Icons.circle, color: devolutions.isEmpty ? Colors.grey : Colors.green),
                label: const Text("Devoluciones"),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 40),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentInvoices = invoices[index];
                    final total = NumberFormatter.convertToMoneyLike(currentInvoices.total);
                    final date = DateTimeTool.formatddMMyy(currentInvoices.createdAt);

                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: viewController.isInSelected(currentInvoices),
                      tileColor: tileColor,
                      onChanged: (value) {
                        if (value == true) {
                          viewController.addToSelected(currentInvoices);
                          return;
                        }

                        viewController.removeFromSelected(currentInvoices);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    final hasDevolution = devolutions.any((element) {
                                      return element.originalInvoiceId == currentInvoices.id;
                                    });

                                    if (hasDevolution) {
                                      return const Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 18,
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  },
                                ),
                                Text("Fact #${currentInvoices.docNumber}"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              total,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),

                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(date),
                        ],
                      ),
                      secondary: TextButton(
                        onPressed: () {
                          showInvoiceViewerDialog(context, currentInvoices);
                        },
                        child: const Text("Ver Factura"),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
