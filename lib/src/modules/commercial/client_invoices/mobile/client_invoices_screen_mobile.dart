import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/mobile/mediator.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/custom_product_commercial_search_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

import '../widgets/product_invoice_card.dart';
import 'invoice_client_menu_screen.dart';

class ClientInvoicesScreenMobile extends StatefulWidget {
  const ClientInvoicesScreenMobile({super.key});

  @override
  State<ClientInvoicesScreenMobile> createState() => _ClientInvoicesScreenMobileState();
}

class _ClientInvoicesScreenMobileState extends State<ClientInvoicesScreenMobile> {
  final viewController = InvoiceMobileViewController();
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
    final cubit = context.read<WriteInvoiceCubit>();

    final mediator = InvoiceMobileMediator.of(context);
    final viewController = mediator.viewController;

    String title = "Facturacion a Clientes";
    if (cubit.isOrder) title = "Orden de compra";

    String saveButton = "Facturar";
    if (cubit.isOrder) saveButton = "Enviar Orden";

    IconData saveIcon = Icons.save;
    if (cubit.isOrder) saveIcon = Icons.send;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final res = await showCommercialProductSearchDelegate(context);
            if (res == null) return;

            viewController.addItem(res);
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        title: Text(title),
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
                            final saleItems = createSaleItemFromCommercial(
                              viewController.items,
                            );
                            await showInvoiceClientMenuScreen(
                              context,
                              saleItems,
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
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: viewController.totalItems.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: formattedTotal,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                        percentDiscount: currentCommercial.selectedDisocunt?.percentValue ?? 0,
                        onRemove: () => viewController.removeItem(currentCommercial),
                        onEdit: () async {
                          final res = await showCommercialProductModal(
                            context,
                            product: currentCommercial.product,
                            commercialProductResult: currentCommercial,
                          );
                          if (res == null) return;
                          viewController.updateItem(
                            currentCommercial,
                            res,
                          );
                        },
                        onChange: () async {
                          final res = await showCommercialProductSearchDelegate(context);
                          if (res == null) return;
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

List<SaleItem> createSaleItemFromCommercial(List<CommercialProductResult> items) {
  final saleItems = items.map((commercial) {
    final product = commercial.product;
    return SaleItem(
      product: ProductItem.fromJson(product.toJson()),
      cost: product.account.averageCost,
      price: commercial.newPrice,
      quantity: commercial.quantity,
      discountPercentage: commercial.discountPercent,
      totalDiscount: commercial.totalDiscount,
      subTotal: commercial.subTotal,
      total: commercial.total,
    );
  }).toList();

  return saleItems;
}
