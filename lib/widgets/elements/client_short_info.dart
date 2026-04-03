import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';

class ClientShortInfo extends StatelessWidget {
  const ClientShortInfo({
    super.key,
    required this.client,
    this.nameFontSize = 16,
    this.showId = true,
    this.showPhone = true,
  });

  final ClientInDb client;
  final double nameFontSize;
  final bool showId;
  final bool showPhone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryTextStyle = TextStyle(
      fontSize: 12,
      color: colorScheme.outline,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showId)
          Row(
            children: [
              Text(
                "#${client.id}",
                style: secondaryTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              // badge is active
              if (client.isActive) ...[
                Badge(
                  label: const Text("Activo"),
                  backgroundColor: Colors.green.shade200,
                  textColor: Colors.green.shade900,
                ),
              ] else ...[
                Badge(
                  label: const Text("Inactivo"),
                  backgroundColor: Colors.red.shade200,
                  textColor: Colors.red.shade900,
                ),
              ],
            ],
          ),
        if (showId) const SizedBox(height: 2),
        Text(
          client.name,
          style: TextStyle(
            fontSize: nameFontSize,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Cédula / CardID
        Row(
          children: [
            Icon(Icons.badge_outlined, size: 14, color: colorScheme.outline),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                client.cardId ?? "Sin Cédula",
                style: secondaryTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (showPhone) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Builder(
                  builder: (context) {
                    String phone = client.phone ?? "";
                    if (phone.isEmpty) phone = "";
                    return Text(
                      phone,
                      style: secondaryTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ],
          ),
        ],

        // Ubicación
        if (client.location != null && client.location!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_city_rounded, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  client.location!,
                  style: secondaryTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Dirección
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.map_outlined, size: 14, color: colorScheme.outline),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                (client.address == null || client.address!.isEmpty) ? "Sin Dirección" : client.address!,
                style: secondaryTextStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
