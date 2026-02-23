import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/widgets/map/launch_map_button.dart';

Future<void> showClientDetailsDialog(BuildContext context, ClientInDb client) async {
  await showDialog(
    context: context,
    builder: (context) => ClientDetailsDialog(client: client),
  );
}

class ClientDetailsDialog extends StatelessWidget {
  final ClientInDb client;

  const ClientDetailsDialog({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(client.name)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailItem(label: 'Cédula/RUC', value: client.cardId ?? 'N/A'),
            _DetailItem(label: 'Teléfono', value: client.phone ?? 'N/A'),
            _DetailItem(label: 'Correo', value: client.email ?? 'N/A'),
            _DetailItem(label: 'Grupo', value: client.group.isEmpty ? 'General' : client.group),
            const Divider(),
            _DetailItem(label: 'Dirección', value: client.address ?? 'N/A'),
            _DetailItem(label: 'Ubicación', value: client.location ?? 'N/A'),
            const Divider(),
            _DetailItem(
              label: 'Saldo Actual',
              value: currencyFormat.format(client.balance / 100),
              valueStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: client.balance > 0 ? Colors.red : Colors.green,
              ),
            ),
            _DetailItem(
              label: 'Límite de Crédito',
              value: currencyFormat.format(client.creditLimit / 100),
            ),
            _DetailItem(
              label: 'Estado de Crédito',
              value: client.isCreditActive ? 'Activo' : 'Inactivo',
              valueStyle: TextStyle(
                color: client.isCreditActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (client.coordinates != null)
          LaunchMapButton(
            latitude: client.coordinates!.latitude,
            longitude: client.coordinates!.longitude,
            label: 'Google Maps',
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ).merge(valueStyle),
          ),
        ],
      ),
    );
  }
}
