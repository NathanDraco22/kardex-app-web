part of '../receipt_cancellation_requests_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadReceiptCancellationRequestsCubit>();
    final current = cubit.statusFilter;

    Widget chip(String label, ReceiptCancellationRequestStatus? status) {
      final selected = current == status;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => cubit.loadRequests(
          status: status,
          updateStatusFilter: true,
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                chip('Pendientes', ReceiptCancellationRequestStatus.pending),
                chip('Aprobadas', ReceiptCancellationRequestStatus.approved),
                chip('Rechazadas', ReceiptCancellationRequestStatus.rejected),
                chip('Canceladas', ReceiptCancellationRequestStatus.cancelled),
                chip('Todas', null),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                PrimaryMenuButton(
                  backgroundColor: AppThemeTokens.indigo,
                  foregroundColor: Colors.white,
                  onPressed: () => context.pushNamed(RouteNames.receiptHistory),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nueva solicitud de anulación'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
