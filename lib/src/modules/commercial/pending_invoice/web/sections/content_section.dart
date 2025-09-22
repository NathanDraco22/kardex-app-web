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

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;

              final currentInvoices = invoices[index];
              final total = NumberFormatter.convertToMoneyLike(currentInvoices.total);
              final date = DateTimeTool.formatddMMyy(currentInvoices.createdAt);

              return CheckboxListTile(
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
                    Expanded(child: Text("Fact #${currentInvoices.docNumber}")),
                    Expanded(
                      child: Text(
                        total,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(date),
              );
            },
          );
        },
      ),
    );
  }
}
