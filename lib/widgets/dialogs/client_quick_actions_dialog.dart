import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

enum ClientQuickAction {
  invoice,
  quote,
  order,
  pendingInvoices,
}

Future<ClientQuickAction?> showClientQuickActionsDialog(
  BuildContext context, {
  required ClientInDb client,
  bool showInvoiceAction = true,
  bool showQuoteAction = true,
  bool showOrderAction = true,
  bool showPendingInvoicesAction = true,
}) {
  return showDialog<ClientQuickAction>(
    context: context,
    builder: (context) => ClientQuickActionsDialog(
      client: client,
      showInvoiceAction: showInvoiceAction,
      showQuoteAction: showQuoteAction,
      showOrderAction: showOrderAction,
      showPendingInvoicesAction: showPendingInvoicesAction,
    ),
  );
}

class ClientQuickActionsDialog extends StatelessWidget {
  const ClientQuickActionsDialog({
    super.key,
    required this.client,
    this.showInvoiceAction = true,
    this.showQuoteAction = true,
    this.showOrderAction = true,
    this.showPendingInvoicesAction = true,
  });

  final ClientInDb client;
  final bool showInvoiceAction;
  final bool showQuoteAction;
  final bool showOrderAction;
  final bool showPendingInvoicesAction;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClientHeader(client: client),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoSection(
                      title: "Ubicación",
                      children: [
                        _InfoLine(
                          icon: Icons.location_city_rounded,
                          label: "Ciudad",
                          value: _displayValue(client.location, "No registrada"),
                        ),
                        _InfoLine(
                          icon: Icons.map_outlined,
                          label: "Dirección",
                          value: _displayValue(client.address, "No registrada"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoSection(
                      title: "Contacto",
                      children: [
                        _InfoLine(
                          icon: Icons.phone_outlined,
                          label: "Teléfono",
                          value: _displayValue(client.phone, "No registrado"),
                        ),
                        _InfoLine(
                          icon: Icons.email_outlined,
                          label: "Correo",
                          value: _displayValue(client.email, "No registrado"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoSection(
                      title: "Información comercial",
                      children: [
                        _InfoLine(
                          icon: Icons.groups_outlined,
                          label: "Grupo",
                          value: _displayValue(client.group, "Sin grupo"),
                        ),
                        _InfoLine(
                          icon: Icons.account_balance_wallet_outlined,
                          label: "Saldo",
                          value: NumberFormatter.convertToMoneyLike(client.balance),
                          valueColor: client.balance > 0 ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                        _InfoLine(
                          icon: Icons.credit_card_outlined,
                          label: "Crédito",
                          value: client.isCreditActive ? "Activo" : "Inactivo",
                          valueColor: client.isCreditActive ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                        _InfoLine(
                          icon: Icons.speed_outlined,
                          label: "Límite de crédito",
                          value: NumberFormatter.convertToMoneyLike(client.creditLimit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _ClientActions(
              showInvoiceAction: showInvoiceAction,
              showQuoteAction: showQuoteAction,
              showOrderAction: showOrderAction,
              showPendingInvoicesAction: showPendingInvoicesAction,
            ),
          ],
        ),
      ),
    );
  }

  static String _displayValue(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = client.name.trim().isEmpty ? "?" : client.name.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.cardId == null || client.cardId!.trim().isEmpty
                      ? "Cédula/RNC: No registrada"
                      : "Cédula/RNC: ${client.cardId}",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _MiniBadge(text: "#${client.id}"),
                    _MiniBadge(
                      text: client.isActive ? "Activo" : "Inactivo",
                      color: client.isActive ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Cerrar",
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.30)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: effectiveColor,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientActions extends StatelessWidget {
  const _ClientActions({
    required this.showInvoiceAction,
    required this.showQuoteAction,
    required this.showOrderAction,
    required this.showPendingInvoicesAction,
  });

  final bool showInvoiceAction;
  final bool showQuoteAction;
  final bool showOrderAction;
  final bool showPendingInvoicesAction;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (showInvoiceAction)
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.pop(context, ClientQuickAction.invoice),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text("Facturar"),
        ),
      if (showQuoteAction)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.pop(context, ClientQuickAction.quote),
          icon: const Icon(Icons.request_quote_outlined),
          label: const Text("Cotización"),
        ),
      if (showOrderAction)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.pop(context, ClientQuickAction.order),
          icon: const Icon(Icons.shopping_cart_outlined),
          label: const Text("Orden de compra"),
        ),
      if (showPendingInvoicesAction)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.pop(context, ClientQuickAction.pendingInvoices),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text("Facturas pendientes"),
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (actions.length == 1) {
            return SizedBox(width: double.infinity, child: actions.first);
          }

          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  actions[i],
                ],
              ],
            );
          }

          final itemWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final action in actions) SizedBox(width: itemWidth, child: action),
            ],
          );
        },
      ),
    );
  }
}
