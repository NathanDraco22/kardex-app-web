part of '../pending_invoice_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadPendingInvoiceCubit>();
    final state = readCubit.state;
    final viewController = PendingInvoiceMediator.of(context).notifier!;
    final client = viewController.selectedClient;

    if (client == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#${client.id}",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (client.cardId != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        client.cardId!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],

                if (client.location != null) ...[
                  Text(
                    client.location!,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
                if (client.address != null) ...[
                  Text(
                    client.address!,
                  ),
                ],

                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      client.phone ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
            Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (client.coordinates != null) ...[
                  LaunchMapButton(
                    latitude: client.coordinates!.latitude,
                    longitude: client.coordinates!.longitude,
                  ),
                ],

                OutlinedButton.icon(
                  onPressed: () {
                    showCreditSessionHistoryDialog(context, client);
                  },
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text("Historial"),
                ),
                Builder(
                  builder: (context) {
                    int total = 0;
                    int totalDevolutions = 0;
                    if (state is ReadInvoiceSuccess) {
                      total = state.invoices.fold(0, (int previousValue, invoice) {
                        total += invoice.totalRemaining;
                        return total;
                      });

                      totalDevolutions = state.devolutions.fold(0, (int previousValue, devolution) {
                        totalDevolutions += devolution.total;
                        return totalDevolutions;
                      });
                    }

                    return ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      onPressed: () async {
                        if (state is! ReadInvoiceSuccess || state.invoices.isEmpty) return;

                        final selectedClient = PendingInvoiceMediator.of(context).notifier?.selectedClient;
                        if (selectedClient == null) return;

                        final maxAmountDouble = total / 100;

                        final amount = await showFastPaymentModal(
                          context,
                          maxAmountToPay: maxAmountDouble,
                          clientName: selectedClient.name,
                        );

                        if (amount == null || amount <= 0) return;

                        if (!context.mounted) return;
                        final authState = getIt<AuthCubit>().state;
                        if (authState is! Authenticated) throw Exception("User or branch not found");
                        final currentUser = authState.session.user;
                        final currentBranch = authState.branch;

                        final amountCents = (amount * 100).round();
                        final (createReceiptPayload, summary) = FastReceiptLogic.allocateFastPayment(
                          paymentAmountCents: amountCents,
                          invoices: state.invoices,
                          devolutions: state.devolutions,
                          client: selectedClient,
                          branchId: currentBranch.id,
                          currentUserId: currentUser.id,
                          currentUserName: currentUser.username,
                        );

                        if (createReceiptPayload == null) return;

                        if (!context.mounted) return;
                        final confirm = await DialogManager.slideToConfirmActionDialog(
                          context,
                          summary,
                        );

                        if (confirm != true) return;

                        if (!context.mounted) return;
                        context.read<WriteReceiptCubit>().createNewReceipt(createReceiptPayload);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text("Abono"),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
