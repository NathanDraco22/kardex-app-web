import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';

/// Barra horizontal compacta para seleccionar o ver detalles del cliente en Mobile y Tablet.
class TerminalClientBar extends StatelessWidget {
  const TerminalClientBar({
    super.key,
    required this.viewController,
    this.height = 36,
  });

  final SaleTerminalViewController viewController;
  final double height;

  @override
  Widget build(BuildContext context) {
    final client = viewController.selectedClient;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (client == null) {
          final selected = await showClientSelectionDialog(context);
          if (selected != null) {
            viewController.selectedClient = selected;
          }
        } else {
          showClientFullDetailsDialog(context, client: client);
        }
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: client == null ? Colors.grey.shade100 : Colors.blue.shade50,
          border: Border.all(
            color: client == null ? Colors.grey.shade300 : Colors.blue.shade200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: client == null ? Colors.grey.shade700 : Colors.blue.shade700,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                client == null ? "Consumidor Final" : client.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: client == null ? Colors.grey.shade800 : Colors.blue.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (client != null) ...[
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Quitar cliente",
                onPressed: () {
                  viewController.selectedClient = null;
                },
              ),
            ] else ...[
              Text(
                "Seleccionar",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
