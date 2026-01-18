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

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 2.0, thickness: 2),
            padding: const EdgeInsets.only(bottom: 40, left: 8, right: 8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;

              final currentInvoice = invoices[index];

              return InvoiceDevolutionTile(
                tileColor: tileColor,
                invoice: currentInvoice,
                devolutions: devolutions,
                isSelected: viewController.isInSelected(currentInvoice),
                onChanged: (value) {
                  if (value == true) {
                    viewController.addToSelected(currentInvoice);
                    return;
                  }

                  viewController.removeFromSelected(currentInvoice);
                },

                onViewInvoice: () {
                  showInvoiceViewerDialog(context, currentInvoice);
                },
                onViewDevolutions: () {
                  final targetDevolution = devolutions
                      .where(
                        (d) => d.originalInvoiceId == currentInvoice.id,
                      )
                      .toList();
                  showDialog(
                    context: context,
                    builder: (context) {
                      final devolutions = state.devolutions;
                      final total = devolutions.fold<int>(
                        0,
                        (previousValue, element) => previousValue + element.total,
                      );
                      return _DevolutionDialog(total: total, devolutions: targetDevolution);
                    },
                  );
                },

                onViewReceipts: () {
                  showInvoiceReceiptsHistoryModal(context, currentInvoice);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DevolutionDialog extends StatelessWidget {
  const _DevolutionDialog({
    required this.total,
    required this.devolutions,
  });

  final int total;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
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
            final circleColor = currentDevolutions.status == DevolutionStatus.confirmed ? Colors.green : Colors.blue;
            return ListTile(
              leading: Icon(Icons.circle, color: circleColor),
              tileColor: index.isOdd ? Colors.white : Colors.grey.shade200,
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
  }
}
