import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/mobile/mediator.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

import '../widgets/product_invoice_card.dart';
import 'invoice_client_menu_screen.dart';
import 'package:kardex_business/kardex_business.dart';

class ClientInvoicesScreenMobile extends StatefulWidget {
  const ClientInvoicesScreenMobile({
    super.key,
    this.pageTitle,
    this.actionButtonLabel,
  });

  final String? pageTitle;
  final String? actionButtonLabel;

  @override
  State<ClientInvoicesScreenMobile> createState() => _ClientInvoicesScreenMobileState();
}

class _ClientInvoicesScreenMobileState extends State<ClientInvoicesScreenMobile> {
  late ClientInvoiceViewController viewController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewController = context.read<WriteInvoiceCubit>().viewController;
    viewController.updatePricesOnClientChange = false;
  }

  @override
  Widget build(BuildContext context) {
    return InvoiceMobileMediator(
      viewController: viewController,
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteInvoiceCubit>();

    final mediator = InvoiceMobileMediator.of(context);
    final viewController = mediator.viewController;

    final mobileScreenWidget = context.findAncestorWidgetOfExactType<ClientInvoicesScreenMobile>();

    String title = mobileScreenWidget?.pageTitle ?? "Facturacion a Clientes";
    if (mobileScreenWidget?.pageTitle == null && writeCubit.isOrder) title = "Orden de compra";

    String saveButton = mobileScreenWidget?.actionButtonLabel ?? "Facturar";
    if (mobileScreenWidget?.actionButtonLabel == null && writeCubit.isOrder) saveButton = "Enviar Orden";

    IconData saveIcon = Icons.save;
    if (writeCubit.isOrder) saveIcon = Icons.send;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final isRestrictStock = writeCubit.documentType != CommercialDocumentType.quote;
            final res = await showCommercialProductSearchDelegate(
              context,
              defaultPriceLevel: viewController.selectedClient?.defaultPriceLevel ?? 1,
              preferredUnitType: viewController.isWholesale ? 'max' : 'min',
              restrictStock: isRestrictStock,
            );
            if (res == null) return;
            if (isRestrictStock && (res.quantity * res.conversionFactor) > res.product.account.availableStock) {
              if (!context.mounted) return;
              await DialogManager.showErrorDialog(
                context,
                "No se puede agregar mas de ${res.product.account.availableStock} unidades",
              );
              return;
            }
            if (res.quantity == 0) return;

            viewController.addItem(res);
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        title: title.contains("(Mayorista)")
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "${title.replaceAll("(Mayorista)", "").trim()} "),
                    const TextSpan(
                      text: "(Mayorista)",
                      style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ListenableBuilder(
            listenable: viewController,
            builder: (context, _) {
              final isEmptyItems = viewController.items.isEmpty;

              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isEmptyItems
                        ? null
                        : () async {
                            await showInvoiceClientMenuScreen(
                              context,
                            );
                          },
                    label: Text(saveButton),
                    icon: Icon(saveIcon),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.bottomLeft,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Text(
                  "Opciones de Navegacion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(FluentIcons.person_20_filled),
              title: const Text("Lista de Clientes"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed("client-list");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
              title: const Text("Consulta Rápida de Producto"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showProductInfoSearchDelegate(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.purple),
              title: const Text("Consulta de Existencias Globales"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed("global-stock-search");
              },
            ),
          ],
        ),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final mediator = InvoiceMobileMediator.of(context);
    final viewController = mediator.viewController;
    final writeCubit = context.read<WriteInvoiceCubit>();
    return Center(
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListenableBuilder(
                  listenable: viewController,
                  builder: (context, _) {
                    final formattedTotal = NumberFormatter.convertToMoneyLike(
                      viewController.totalAmount,
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Productos: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: viewController.totalItems.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Total: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: formattedTotal,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: ListenableBuilder(
                listenable: viewController,
                builder: (context, _) {
                  return ListView.separated(
                    itemCount: viewController.items.length,
                    padding: const EdgeInsets.only(
                      bottom: 96.0,
                      top: 16,
                      left: 8,
                      right: 8,
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 4,
                    ),
                    itemBuilder: (context, index) {
                      final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final currentCommercial = viewController.items[index];

                      return ProductInvoiceCard(
                        tileColor: tileColor,
                        item: currentCommercial,
                        percentDiscount: currentCommercial.selectedDiscount?.percentValue ?? 0,
                        onRemove: () => viewController.removeItem(currentCommercial),
                        onEdit: () async {
                          final isRestrictStock = writeCubit.documentType != CommercialDocumentType.quote;
                          final res = await showCommercialProductModal(
                            context,
                            product: currentCommercial.product,
                            commercialProductResult: currentCommercial,
                            restrictStock: isRestrictStock,
                          );
                          if (res == null) return;
                          if (isRestrictStock &&
                              (res.quantity * res.conversionFactor) > res.product.account.availableStock) {
                            if (!context.mounted) return;
                            await DialogManager.showErrorDialog(
                              context,
                              "No se puede agregar mas de ${res.product.account.availableStock} unidades",
                            );
                            return;
                          }
                          if (res.quantity == 0) return;
                          viewController.updateItem(
                            currentCommercial,
                            res,
                          );
                        },
                        onChange: () async {
                          final isRestrictStock = writeCubit.documentType != CommercialDocumentType.quote;
                          final res = await showCommercialProductSearchDelegate(
                            context,
                            defaultPriceLevel: viewController.selectedClient?.defaultPriceLevel ?? 1,
                            preferredUnitType: viewController.isWholesale ? 'max' : 'min',
                            restrictStock: isRestrictStock,
                          );
                          if (res == null) return;
                          if (isRestrictStock &&
                              (res.quantity * res.conversionFactor) > res.product.account.availableStock) {
                            if (!context.mounted) return;
                            await DialogManager.showErrorDialog(
                              context,
                              "No se puede agregar mas de ${res.product.account.availableStock} unidades",
                            );
                            return;
                          }
                          if (res.quantity == 0) return;
                          viewController.updateItem(
                            currentCommercial,
                            res,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
