part of '../no_paid_invoice_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = NoPaidInvoiceMediator.of(context).notifier!;
    final client = viewController.selectedClient;

    if (client == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "${client.id}-${client.name}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              client.location ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              client.address ?? '',
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Telefono: ${client.phone ?? ''} ',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Correo: ${client.email ?? ''} ',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
