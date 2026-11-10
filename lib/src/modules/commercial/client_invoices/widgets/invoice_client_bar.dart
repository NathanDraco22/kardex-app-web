import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';

/// Barra compacta para mostrar y cambiar el cliente de la factura actual.
class InvoiceClientBar extends StatelessWidget {
  const InvoiceClientBar({
    super.key,
    required this.viewController,
  });

  final ClientInvoiceViewController viewController;

  Future<void> _selectClient(BuildContext context) async {
    final selected = await showClientSelectionDialog(context);
    if (selected == null || !context.mounted) return;
    viewController.selectedClient = selected;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        final client = viewController.selectedClient;
        final hasClient = client != null;
        final initial = (client?.name.trim().isNotEmpty ?? false)
            ? client!.name.trim().substring(0, 1).toUpperCase()
            : "?";
        final location = client?.location?.trim();
        final subtitle = hasClient
            ? "#${client.id}${location != null && location.isNotEmpty ? " • $location" : ""}"
            : "Toca para buscar un cliente";

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (client == null) {
                _selectClient(context);
              } else {
                showClientFullDetailsDialog(context, client: client);
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                color: hasClient ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasClient ? Colors.blue.shade200 : Colors.grey.shade300,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: hasClient ? Colors.blue.shade100 : Colors.grey.shade200,
                      child: hasClient
                          ? Text(
                              initial,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            )
                          : Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Colors.grey.shade700,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasClient ? client.name : "Seleccionar cliente",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: hasClient ? Colors.blue.shade900 : Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: hasClient ? Colors.blue.shade700 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (hasClient) ...[
                      if (client.balance > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          NumberFormatter.convertToMoneyLike(client.balance),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                      IconButton(
                        tooltip: "Cambiar cliente",
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                        onPressed: () => _selectClient(context),
                        icon: Icon(
                          Icons.swap_horiz,
                          size: 19,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ] else
                      Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
