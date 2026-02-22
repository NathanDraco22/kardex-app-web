part of '../pending_invoice_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = PendingInvoiceMediator.of(context).notifier!;
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

            if (client.coordinates != null) ...[
              LaunchMapButton(
                latitude: client.coordinates!.latitude,
                longitude: client.coordinates!.longitude,
              ),
            ],

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
