import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/search_product_commercial_dialog.dart';

import '../web/mediator.dart';
import 'more_action_row_button.dart';

import '../view_controller.dart';

class ClientInvoiceTable extends StatefulWidget {
  const ClientInvoiceTable({
    super.key,
    required this.controller,
    required this.restrictQuantity,
  });

  final ClientInvoiceViewController controller;
  final bool restrictQuantity;

  @override
  State<ClientInvoiceTable> createState() => _ClientInvoiceTableState();
}

class _ClientInvoiceTableState extends State<ClientInvoiceTable> {
  ScrollController scrollController = ScrollController();
  bool? _isAscending;
  bool _isSortingInternal = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    scrollController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (!_isSortingInternal) {
      setState(() {
        _isAscending = null;
      });
    }
  }

  void _toggleSort() {
    final nextAscending = !(_isAscending ?? false);

    _isSortingInternal = true;
    widget.controller.items.sort((a, b) {
      final nameA = a.product.name.toLowerCase();
      final nameB = b.product.name.toLowerCase();
      return nextAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    setState(() {
      _isAscending = nextAscending;
    });

    widget.controller.refresh();
    _isSortingInternal = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Producto", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: _isAscending == null
                            ? "Ordenar productos (A-Z)"
                            : _isAscending!
                            ? "Ordenar Z-A"
                            : "Ordenar A-Z",
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort_by_alpha, size: 16),
                            if (_isAscending != null)
                              Icon(
                                _isAscending! ? Icons.arrow_downward : Icons.arrow_upward,
                                size: 11,
                              ),
                          ],
                        ),
                        onPressed: _toggleSort,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "Cantidad",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "Precio Unitario",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "SubTotal",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "Descuento",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "IVA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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

                          widget.controller.addItem(res);
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

  Iterable<Widget> _buildRow(BuildContext context, ClientInvoiceViewController controller) sync* {
    for (var i = 0; i < controller.items.length; i++) {
      final currentItem = controller.items[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield InvoiceTableRow(
        key: ValueKey(currentItem),
        color: color,
        item: currentItem,
        onRemove: (item) => controller.removeItem(item),
        onChange: (item) async {
          final res = await showSearchProductCommercialDialog(context, product: item.product);
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
          controller.updateItem(item, res);
        },
        onEdit: (item) async {
          final res = await showCommercialProductDialog(
            context,
            product: item.product,
            commercialProductResult: item,
          );
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
          controller.updateItem(item, res);
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

  final CommercialProductResult item;

  final void Function(CommercialProductResult item) onRemove;
  final void Function(CommercialProductResult item) onEdit;
  final void Function(CommercialProductResult item) onChange;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final price = NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice);
    final edittedPrice = NumberFormatter.convertToMoneyLike(item.newPrice);
    final subTotal = NumberFormatter.convertToMoneyLike(item.subTotal);
    final totalDiscount = NumberFormatter.convertToMoneyLike(item.totalDiscount);
    final percenValue = item.discountPercent;
    final total = NumberFormatter.convertToMoneyLike(item.total);
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
                  Text(item.quantity.toString()),
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
