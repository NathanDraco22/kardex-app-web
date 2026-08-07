import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/more_action_row_button.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_dialog.dart';
import 'package:kardex_app_front/widgets/incremental_textfield.dart';

class AnonInvoiceTable extends StatefulWidget {
  const AnonInvoiceTable({
    super.key,
    required this.controller,
  });

  final AnonInvoiceViewController controller;

  @override
  State<AnonInvoiceTable> createState() => _AnonInvoiceTableState();
}

class _AnonInvoiceTableState extends State<AnonInvoiceTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
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
        ),
        const Divider(
          height: 0.0,
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
                      ElevatedCtrlButton(
                        hotKey: "1",
                        icon: Icons.add,
                        label: "Agregar Producto",
                        onPressed: () async {
                          final res = await showSearchProductCommercialDialog(
                            context,
                            isDirectSale: true,
                          );
                          if (!context.mounted) return;
                          if (res == null) return;
                          if (res.product.account.availableStock == 0 ||
                              res.product.account.availableStock < (res.quantity * res.conversionFactor)) {
                            DialogManager.showInfoDialog(
                              context,
                              "No hay stock disponible",
                            );
                            return;
                          }
                          widget.controller.addItem(res);
                        },
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

  Iterable<Widget> _buildRow(BuildContext context, AnonInvoiceViewController controller) sync* {
    for (var i = 0; i < controller.items.length; i++) {
      final currentItem = controller.items[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield InvoiceTableRow(
        key: ValueKey(currentItem),
        color: color,
        item: currentItem,
        controller: controller,
        onRemove: (item) => controller.removeItem(item),
        onChange: (item) async {
          final res = await showSearchProductCommercialDialog(
            context,
            product: item.product,
            isDirectSale: true,
          );
          if (res == null) return;
          if (res.product.account.availableStock == 0 ||
              res.product.account.availableStock < (res.quantity * res.conversionFactor)) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No hay stock disponible",
            );
            return;
          }
          controller.updateItem(item, res);
        },
        onEdit: (item) async {
          final res = await showCommercialProductDialog(
            context,
            product: item.product,
            commercialProductResult: item,
          );
          if (res == null) return;
          if (res.product.account.availableStock == 0 ||
              res.product.account.availableStock < (res.quantity * res.conversionFactor)) {
            if (!context.mounted) return;
            await DialogManager.showErrorDialog(
              context,
              "No hay stock disponible",
            );
            return;
          }
          controller.updateItem(item, res);
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
    required this.controller,
    required this.onRemove,
    required this.onEdit,
    required this.onChange,
  });

  final Color color;
  final CommercialProductResult item;
  final AnonInvoiceViewController controller;

  final void Function(CommercialProductResult item) onRemove;
  final void Function(CommercialProductResult item) onEdit;
  final void Function(CommercialProductResult item) onChange;

  @override
  State<InvoiceTableRow> createState() => _InvoiceTableRowState();
}

class _InvoiceTableRowState extends State<InvoiceTableRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final product = widget.item.product;

    final price = NumberFormatter.convertToMoneyLike(
      widget.item.newPrice * widget.item.conversionFactor,
    );
    final totalDiscount = NumberFormatter.convertToMoneyLike(widget.item.totalDiscount);
    final percenValue = widget.item.discountPercent;
    final total = NumberFormatter.convertToMoneyLike(widget.item.total);
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: widget.color,
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 72,
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
                            widget.controller.refresh();
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
                            maxLines: 3,
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
                                child: UnitDisplayer(
                                  unitName: widget.item.selectedUnitName,
                                  conversionFactor: widget.item.conversionFactor,
                                  fallbackUnitName: product.unitName,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  NumberFormatter.formatDisplayStock(
                                    product.account.availableStock,
                                    widget.item.conversionFactor,
                                  ),
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
                  maxValue:
                      widget.item.product.account.availableStock ~/ widget.item.conversionFactor,
                  initialValue: widget.item.quantity,
                  onChanged: (value) {
                    widget.item.quantity = value;
                    widget.controller.refresh();
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
