import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

void showUnpaidClientStatsDialog(BuildContext context, {required ClientInDb client}) {
  showDialog(
    context: context,
    builder: (context) {
      return UnpaidClientStatsDialog(client: client);
    },
  );
}

class UnpaidClientStatsDialog extends StatelessWidget {
  const UnpaidClientStatsDialog({super.key, required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().startOfDay();

    int daysSinceCorte = 0;
    String corteText = "No asignado";
    if (client.lastCreditStart != null) {
      daysSinceCorte = now.difference(client.lastCreditStart!.startOfDay()).inDays;
      corteText = "${DateTimeTool.formatddMMyy(client.lastCreditStart!)} ($daysSinceCorte días)";
    }

    int daysSinceAbono = 0;
    String abonoText = "Sin abonos previos";
    if (client.lastReceiptDate != null) {
      daysSinceAbono = now.difference(client.lastReceiptDate!.startOfDay()).inDays;
      abonoText = "${DateTimeTool.formatddMMyy(client.lastReceiptDate!)} ($daysSinceAbono días de inactividad)";
    }

    return AlertDialog(
      title: const Text("Estadísticas de Impago"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${client.id} - ${client.name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  if (client.phone != null) {
                    launchUrl(Uri.parse("tel:${client.phone}"));
                  }
                },
                label: Text(client.phone ?? "Sin teléfono"),
              ),

              TextButton.icon(
                icon: const Icon(Icons.email),
                onPressed: () {
                  if (client.email != null) {
                    launchUrl(Uri.parse("mailto:${client.email}"));
                  }
                },
                label: Text(client.email ?? "Sin correo"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: "Inicio de Crédito (Día de Corte)",
            value: corteText,
            icon: Icons.calendar_month,
            color: _getColorForDays(daysSinceCorte),
          ),
          const SizedBox(height: 8),
          _StatCard(
            title: "Último Abono Registrado",
            value: abonoText,
            icon: Icons.payments_outlined,
            color: client.lastReceiptDate == null ? Colors.red.shade100 : _getColorForDays(daysSinceAbono),
          ),

          TextButton.icon(
            icon: const Icon(Icons.person),
            onPressed: () {
              showClientFullDetailsDialog(context, client: client);
            },
            label: const Text("Ver Mas..."),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cerrar"),
        ),
      ],
    );
  }

  Color? _getColorForDays(int days) {
    if (days > 37) return Colors.red.shade100;
    if (days > 30) return Colors.amber.shade100;
    return Colors.grey.shade100;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.blueGrey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
