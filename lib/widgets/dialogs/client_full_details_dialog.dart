import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void showClientFullDetailsDialog(BuildContext context, {required ClientInDb client}) {
  showDialog(
    context: context,
    builder: (context) {
      return ClientDetailsDialog(client: client);
    },
  );
}

class ClientDetailsDialog extends StatelessWidget {
  const ClientDetailsDialog({
    super.key,
    required this.client,
  });

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Detalles del Cliente"),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailItem(title: "Nombre Completo", value: client.name),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(title: "Cédula", value: client.cardId ?? "No registrada"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ContactItem(
                      title: "Teléfono",
                      value: client.phone ?? "No registrado",
                      icon: Icons.phone,
                      onTap: client.phone != null ? () => launchUrl(Uri.parse("tel:${client.phone}")) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailItem(title: "Ubicación (Ciudad)", value: client.location ?? "No registrada"),
              const SizedBox(height: 12),
              _DetailItem(title: "Dirección", value: client.address ?? "No registrada"),
              const SizedBox(height: 12),
              _ContactItem(
                title: "Correo Electrónico",
                value: client.email ?? "No registrado",
                icon: Icons.email,
                onTap: client.email != null ? () => launchUrl(Uri.parse("mailto:${client.email}")) : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(title: "Grupo de Clientes", value: client.group),
                  ),
                  const SizedBox(width: 12),
                  _CoordinateButton(client: client),
                ],
              ),
              const SizedBox(height: 12),
              if (client.balance > 0) ...[
                _BalanceCard(balance: client.balance),
                const SizedBox(height: 12),
              ],
              _ReferencesButton(client: client),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatusBadge(
                      title: "Estado",
                      isActive: client.isActive,
                      activeText: "Activo",
                      inactiveText: "Inactivo",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusBadge(
                      title: "Crédito",
                      isActive: client.isCreditActive,
                      activeText: "Activo",
                      inactiveText: "Inactivo",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: onTap != null ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: onTap != null ? Colors.blue.shade200 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: onTap != null ? Colors.blue.shade700 : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: onTap != null ? Colors.blue.shade700 : Colors.black87,
                      fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CoordinateButton extends StatelessWidget {
  const _CoordinateButton({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = client.coordinates != null;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        foregroundColor: hasCoordinates ? Colors.blue : Colors.grey,
        side: BorderSide(color: hasCoordinates ? Colors.blue.shade200 : Colors.grey.shade300),
      ),
      icon: Icon(hasCoordinates ? Icons.location_on : Icons.location_off),
      label: Text(hasCoordinates ? "Ver Mapa" : "Sin Coordenadas"),
      onPressed: hasCoordinates
          ? () {
              final coords = client.coordinates!;
              showMapBottomModal(
                context,
                title: "Ubicación de ${client.name}",
                initialCenter: LatLng(coords.latitude, coords.longitude),
                markers: [
                  MarkerData(
                    title: client.name,
                    coordinates: coords,
                  ),
                ],
              );
            }
          : null,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final num balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Saldo Pendiente",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
                Text(
                  "C\$ ${(balance / 100).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencesButton extends StatelessWidget {
  const _ReferencesButton({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    final refsCount = client.personalReferences.length;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: refsCount > 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      onPressed: refsCount > 0
          ? () {
              showClientPersonalReferenceViewer(
                context,
                client.personalReferences,
              );
            }
          : null,
      icon: const Icon(Icons.group),
      label: Text("Referencias Personales ($refsCount)"),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.title,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
  });

  final String title;
  final bool isActive;
  final String activeText;
  final String inactiveText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? activeText : inactiveText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
