part of '../no_paid_invoice_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = NoPaidInvoiceMediator.of(context);
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

              final currentInvoice = invoices[index];
              final total = NumberFormatter.convertToMoneyLike(currentInvoice.total);
              final date = DateTimeTool.formatddMMyy(currentInvoice.createdAt);

              return ListTile(
                tileColor: tileColor,
                onTap: () {
                  if (currentInvoice.amountPaid > 0) {
                    DialogManager.showInfoDialog(context, "No puedes devolver una factura con pagos");
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return DevolutionSelectionScreen(
                          invoice: currentInvoice,
                          devolutions: devolutions,
                        );
                      },
                    ),
                  );
                },
                title: Row(
                  children: [
                    Expanded(
                      child: Text("Fact #${currentInvoice.docNumber}"),
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
              );
            },
          );
        },
      ),
    );
  }
}
