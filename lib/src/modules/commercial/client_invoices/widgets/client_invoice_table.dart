import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/search_product_commercial_dialog.dart';

import '../web/mediator.dart';
import 'more_action_row_button.dart';

class ClientInvoiceItem {
  final CommercialProductResult commercial;

  ClientInvoiceItem(this.commercial);
}

class ClientInvoiceTableController extends ChangeNotifier {
  List<ClientInvoiceItem> items = [];

  int get total {
    var total = 0.0;

    for (var item in items) {
      total += item.commercial.total;
    }
    return total.toInt();
  }

  void addRow(ClientInvoiceItem item) {
    items.add(item);
    notifyListeners();
  }

  void removeRow(ClientInvoiceItem item) {
    items.remove(item);
    notifyListeners();
  }

  void updateRow(ClientInvoiceItem oldItem, ClientInvoiceItem newItem) {
    final index = items.indexOf(oldItem);
    items[index] = newItem;
    notifyListeners();
  }
}

class ClientInvoiceTable extends StatefulWidget {
  const ClientInvoiceTable({
    super.key,
    required this.controller,
    required this.restrictQuantity,
  });

  final ClientInvoiceTableController controller;
  final bool restrictQuantity;

  @override
  State<ClientInvoiceTable> createState() => _ClientInvoiceTableState();
}

class _ClientInvoiceTableState extends State<ClientInvoiceTable> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Center(child: Text("Producto")),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("Cantidad")),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("Precio Unitario")),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("SubTotal")),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("Descuento")),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("IVA")),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("Total")),
            ),
          ],
        ),
        const Divider(
          thickness: 2,
        ),

        Expanded(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return ListView(
                // reverse: true,
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  ..._buildRow(context, widget.controller),
                  const Divider(
                    height: 0.0,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const SizedBox(width: 32),
                      ElevatedButton.icon(
                        focusNode: FocusNode()..requestFocus(),
                        onPressed: () async {
                          final res = await showSearchProductCommercialDialog(
                            context,
                          );

                          if (res == null) return;
                          if (res.quantity == 0) return;
                          if (widget.restrictQuantity &&
                              (res.quantity > res.product.account.availableStock ||
                                  res.product.account.availableStock == 0)) {
                            if (!context.mounted) return;
                            await DialogManager.showErrorDialog(
                              context,
                              "No se puede agregar mas de ${res.product.account.availableStock} unidades",
                            );
                            return;
                          }

                          widget.controller.addRow(ClientInvoiceItem(res));
                          if (!context.mounted) return;
                          ClientInvoiceWebMediator.of(context).viewController.refresh();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Producto"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Iterable<Widget> _buildRow(BuildContext context, ClientInvoiceTableController controller) sync* {
    for (var i = 0; i < controller.items.length; i++) {
      final currentItem = controller.items[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield InvoiceTableRow(
        key: ValueKey(currentItem),
        color: color,
        item: currentItem,
        onRemove: (item) => controller.removeRow(item),
        onChange: (item) async {
          final res = await showSearchProductCommercialDialog(context, product: item.commercial.product);
          if (res == null) return;
          if (widget.restrictQuantity &&
              (res.quantity > res.product.account.availableStock || res.product.account.availableStock == 0)) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No se puede agregar mas de ${res.product.account.availableStock} unidades",
            );
            return;
          }
          if (res.quantity == 0) return;
          controller.updateRow(item, ClientInvoiceItem(res));
        },
        onEdit: (item) async {
          final res = await showCommercialProductDialog(
            context,
            product: item.commercial.product,
            commercialProductResult: item.commercial,
          );
          if (res == null) return;
          if (widget.restrictQuantity && res.quantity > res.product.account.availableStock) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No se puede agregar mas de ${res.product.account.availableStock} unidades",
            );
            return;
          }
          if (res.quantity == 0) return;
          controller.updateRow(item, ClientInvoiceItem(res));
        },
      );
    }
  }
}

class InvoiceTableRow extends StatelessWidget {
  const InvoiceTableRow({
    super.key,
    required this.color,
    required this.item,
    required this.onRemove,
    required this.onEdit,
    required this.onChange,
  });

  final Color color;

  final ClientInvoiceItem item;

  final void Function(ClientInvoiceItem item) onRemove;
  final void Function(ClientInvoiceItem item) onEdit;
  final void Function(ClientInvoiceItem item) onChange;

  @override
  Widget build(BuildContext context) {
    final product = item.commercial.product;
    final price = NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice);
    final edittedPrice = NumberFormatter.convertToMoneyLike(item.commercial.newPrice);
    final subTotal = NumberFormatter.convertToMoneyLike(item.commercial.subTotal);
    final totalDiscount = NumberFormatter.convertToMoneyLike(item.commercial.totalDiscount);
    final percenValue = item.commercial.discountPercent;
    final total = NumberFormatter.convertToMoneyLike(item.commercial.total);
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: color,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  MoreActionInvoiceRowButton(
                    popUpItems: [
                      PopupMenuItem(
                        child: const Text("Cambiar"),
                        onTap: () => onChange(item),
                      ),
                      PopupMenuItem(
                        child: const Text("Editar"),
                        onTap: () => onEdit(item),
                      ),
                      PopupMenuItem(
                        child: const Text("Eliminar"),
                        onTap: () => onRemove(item),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DisplayProductCode(product: product),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.brandName,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                product.unitName,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(item.commercial.quantity.toString()),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      decoration: price != edittedPrice ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    edittedPrice,
                    style: TextStyle(
                      fontWeight: price != edittedPrice ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(subTotal),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(totalDiscount),
                  Text("($percenValue%)"),
                ],
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("0"),
                  Text("(0%)"),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(total),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
