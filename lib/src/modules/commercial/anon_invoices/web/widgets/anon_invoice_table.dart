import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/web/mediator.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/more_action_row_button.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/search_product_commercial_dialog.dart';
import 'package:kardex_app_front/widgets/incremental_textfield.dart';

class AnonInvoiceItem {
  final CommercialProductResult commercial;

  AnonInvoiceItem(this.commercial);
}

class AnonInvoiceTableController extends ChangeNotifier {
  List<AnonInvoiceItem> items = [];

  int get total {
    var total = 0.0;

    for (var item in items) {
      total += item.commercial.total;
    }
    return total.toInt();
  }

  void addRowIfNotExists(AnonInvoiceItem item) {
    final isExists = items.any(
      (element) => element.commercial.product.id == item.commercial.product.id,
    );
    if (isExists) return;
    items.add(item);
    notifyListeners();
  }

  void removeRow(AnonInvoiceItem item) {
    items.remove(item);
    notifyListeners();
  }

  void updateRow(AnonInvoiceItem oldItem, AnonInvoiceItem newItem) {
    final index = items.indexOf(oldItem);
    items[index] = newItem;
    notifyListeners();
  }

  void refresh() => notifyListeners();
}

class AnonInvoiceTable extends StatefulWidget {
  const AnonInvoiceTable({
    super.key,
    required this.controller,
  });

  final AnonInvoiceTableController controller;

  @override
  State<AnonInvoiceTable> createState() => _AnonInvoiceTableState();
}

class _AnonInvoiceTableState extends State<AnonInvoiceTable> {
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
                            isDirectSale: true,
                          );
                          if (!context.mounted) return;
                          if (res == null) return;
                          if (res.product.account.availableStock == 0 ||
                              res.product.account.availableStock < res.quantity) {
                            DialogManager.showInfoDialog(
                              context,
                              "No hay stock disponible",
                            );
                            return;
                          }
                          widget.controller.addRowIfNotExists(AnonInvoiceItem(res));
                          if (!context.mounted) return;
                          // ClientInvoiceWebMediator.of(context).viewController.refresh();
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

  Iterable<Widget> _buildRow(BuildContext context, AnonInvoiceTableController controller) sync* {
    for (var i = 0; i < controller.items.length; i++) {
      final currentItem = controller.items[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield InvoiceTableRow(
        key: ValueKey(currentItem),
        color: color,
        item: currentItem,
        onRemove: (item) => controller.removeRow(item),
        onChange: (item) async {
          final res = await showSearchProductCommercialDialog(
            context,
            product: item.commercial.product,
            isDirectSale: true,
          );
          if (res == null) return;
          if (res.product.account.availableStock == 0 || res.product.account.availableStock < res.quantity) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No hay stock disponible",
            );
            return;
          }
          controller.updateRow(item, AnonInvoiceItem(res));
        },
        onEdit: (item) async {
          final res = await showCommercialProductDialog(
            context,
            product: item.commercial.product,
            commercialProductResult: item.commercial,
          );
          if (res == null) return;
          if (res.product.account.availableStock == 0 || res.product.account.availableStock < res.quantity) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No hay stock disponible",
            );
            return;
          }
          controller.updateRow(item, AnonInvoiceItem(res));
        },
      );
    }
  }
}

class InvoiceTableRow extends StatefulWidget {
  const InvoiceTableRow({
    super.key,
    required this.color,
    required this.item,
    required this.onRemove,
    required this.onEdit,
    required this.onChange,
  });

  final Color color;

  final AnonInvoiceItem item;

  final void Function(AnonInvoiceItem item) onRemove;
  final void Function(AnonInvoiceItem item) onEdit;
  final void Function(AnonInvoiceItem item) onChange;

  @override
  State<InvoiceTableRow> createState() => _InvoiceTableRowState();
}

class _InvoiceTableRowState extends State<InvoiceTableRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final product = widget.item.commercial.product;

    final price = NumberFormatter.convertToMoneyLike(widget.item.commercial.newPrice);
    final totalDiscount = NumberFormatter.convertToMoneyLike(widget.item.commercial.totalDiscount);
    final percenValue = widget.item.commercial.discountPercent;
    final total = NumberFormatter.convertToMoneyLike(widget.item.commercial.total);
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: widget.color,
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    MoreActionInvoiceRowButton(
                      popUpItems: [
                        PopupMenuItem(
                          child: const ListTile(
                            title: Text("Cambiar"),
                            leading: Icon(Icons.swap_horiz),
                          ),
                          onTap: () {
                            widget.onChange(widget.item);
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            title: Text("Editar"),
                            leading: Icon(Icons.edit),
                          ),
                          onTap: () {
                            widget.onEdit(widget.item);
                            AnonInvoiceWebMediator.of(context).viewController.refresh();
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            title: Text("Eliminar"),
                            leading: Icon(Icons.delete),
                          ),
                          onTap: () => widget.onRemove(widget.item),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 12),
                              Text(product.displayCode),
                            ],
                          ),
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

                              Expanded(
                                child: Text(
                                  product.account.availableStock.toString(),
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
                child: IncrementalTextField(
                  maxValue: widget.item.commercial.product.account.availableStock,
                  initialValue: widget.item.commercial.quantity,
                  onChanged: (value) {
                    widget.item.commercial.quantity = value;
                    AnonInvoiceWebMediator.of(context).viewController.refresh();
                    setState(() {});
                  },
                ),
              ),
              Flexible(
                key: ValueKey(price),
                fit: FlexFit.tight,
                child: SizedBox(
                  height: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
