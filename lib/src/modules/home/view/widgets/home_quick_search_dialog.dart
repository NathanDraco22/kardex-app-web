import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/client_invoices_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/pending_invoice_web_screen.dart';
import 'package:kardex_app_front/widgets/dialogs/client_quick_actions_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

enum _QuickSearchOption {
  client,
  product,
}

bool _hasAccess(BuildContext context, Enum permission) {
  return AccessManager().hasCurrentAccess(context, permission.name);
}

bool canShowClientQuickSearch(BuildContext context) {
  final isCommerce = getIt<AuthCubit>().currentBranch?.isCommerce ?? true;
  if (!isCommerce) return false;

  return _hasAccess(context, CommercialSubModules.createInvoice) ||
      _hasAccess(context, Modules.pendingInvoices) ||
      _hasAccess(context, CommercialSubModules.pendingInvoices);
}

bool canShowProductQuickSearch(BuildContext context) {
  return _hasAccess(context, Modules.products) ||
      _hasAccess(context, Modules.inventory) ||
      _hasAccess(context, CommercialSubModules.createInvoice);
}

bool canShowHomeQuickSearch(BuildContext context) {
  return canShowClientQuickSearch(context) || canShowProductQuickSearch(context);
}

Future<void> showHomeQuickSearchDialog(BuildContext context) async {
  final canSearchClient = canShowClientQuickSearch(context);
  final canSearchProduct = canShowProductQuickSearch(context);

  if (!canSearchClient && !canSearchProduct) return;

  final selectedOption = await showDialog<_QuickSearchOption>(
    context: context,
    builder: (context) => _HomeQuickSearchDialog(
      canSearchClient: canSearchClient,
      canSearchProduct: canSearchProduct,
    ),
  );

  if (selectedOption == null || !context.mounted) return;

  if (selectedOption == _QuickSearchOption.product) {
    await showProductInfoSearchDelegate(context);
    return;
  }

  final client = await showClientSelectionDialog(context);
  if (client == null || !context.mounted) return;

  final action = await showClientQuickActionsDialog(
    context,
    client: client,
    showInvoiceAction: _hasAccess(context, CommercialSubModules.createInvoice),
    showPendingInvoicesAction:
        _hasAccess(context, Modules.pendingInvoices) || _hasAccess(context, CommercialSubModules.pendingInvoices),
  );

  if (action == null || !context.mounted) return;

  if (action == ClientQuickAction.invoice) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientInvoiceScreen(initialClient: client),
      ),
    );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PendingInvoiceWebScreen(client: client),
    ),
  );
}

class _HomeQuickSearchDialog extends StatelessWidget {
  const _HomeQuickSearchDialog({
    required this.canSearchClient,
    required this.canSearchProduct,
  });

  final bool canSearchClient;
  final bool canSearchProduct;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      title: Row(
        children: [
          const Expanded(child: Text("Búsqueda rápida")),
          IconButton(
            tooltip: "Cerrar",
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSearchClient)
              _QuickSearchCard(
                icon: Icons.person_search_rounded,
                color: Colors.blue.shade700,
                title: "Buscar cliente",
                subtitle: "Facturar o consultar facturas pendientes",
                onTap: () => Navigator.pop(context, _QuickSearchOption.client),
              ),
            if (canSearchClient && canSearchProduct) const SizedBox(height: 12),
            if (canSearchProduct)
              _QuickSearchCard(
                icon: Icons.inventory_2_outlined,
                color: Colors.teal.shade700,
                title: "Buscar producto",
                subtitle: "Consultar precio, existencias y detalles",
                onTap: () => Navigator.pop(context, _QuickSearchOption.product),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickSearchCard extends StatelessWidget {
  const _QuickSearchCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
