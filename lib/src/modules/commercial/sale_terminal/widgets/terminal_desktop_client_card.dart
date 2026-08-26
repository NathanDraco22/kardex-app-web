import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';

/// Tarjeta de cliente para Desktop que abarca dos filas de altura,
/// mostrando avatar, nombre, badge de crédito, teléfono y botones de acción.
class TerminalDesktopClientCard extends StatelessWidget {
  const TerminalDesktopClientCard({
    super.key,
    required this.viewController,
    this.height = 82,
  });

  final SaleTerminalViewController viewController;
  final double height;

  @override
  Widget build(BuildContext context) {
    final client = viewController.selectedClient;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        if (client == null) {
          final selected = await showClientSelectionDialog(context);
          if (selected != null) {
            viewController.selectedClient = selected;
          }
        } else {
          showClientFullDetailsDialog(context, client: client);
        }
        viewController.requestSearchFocus();
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: client == null ? Colors.grey.shade50 : Colors.blue.shade50.withValues(alpha: 0.6),
          border: Border.all(
            color: client == null ? Colors.grey.shade300 : Colors.blue.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar / Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: client == null ? Colors.grey.shade200 : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                client == null ? Icons.person_outline : Icons.person,
                size: 24,
                color: client == null ? Colors.grey.shade700 : Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 12),
            // Client info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "CLIENTE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: client == null ? Colors.grey.shade600 : Colors.blue.shade700,
                        ),
                      ),
                      if (client?.isCreditActive == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade300, width: 0.5),
                          ),
                          child: Text(
                            "Crédito",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    client == null ? "Consumidor Final" : client.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: client == null ? Colors.grey.shade800 : Colors.blue.shade900,
                    ),
                  ),
                  if (client != null && client.phone != null && client.phone!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Tel: ${client.phone}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ] else if (client == null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Toca para asignar un cliente",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            if (client != null) ...[
              IconButton(
                icon: Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                tooltip: "Ver detalles del cliente",
                onPressed: () {
                  showClientFullDetailsDialog(context, client: client);
                  viewController.requestSearchFocus();
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                tooltip: "Quitar cliente",
                onPressed: () {
                  viewController.selectedClient = null;
                  viewController.requestSearchFocus();
                },
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final selected = await showClientSelectionDialog(context);
                  if (selected != null) {
                    viewController.selectedClient = selected;
                  }
                  viewController.requestSearchFocus();
                },
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text("Seleccionar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
