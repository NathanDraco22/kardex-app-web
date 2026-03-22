import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';

class ProductRow {
  ProductRow({
    required this.product,
    this.quantity = 0,
    this.unitaryCost = 0,
    this.expirationDate,
    this.editableCost = false,
    this.haveExpirationDate = true,
  });

  ProductInDb product;
  int quantity = 0;
  int unitaryCost = 0;
  DateTime? expirationDate;

  bool editableCost;
  bool haveExpirationDate;

  int get subTotal => (quantity * unitaryCost);
}

class ProductTableController extends ChangeNotifier {
  List<ProductRow> rows = [];

  int get total => rows.fold<int>(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );

  bool get hasRows => rows.isNotEmpty;

  void refresh() => notifyListeners();

  void clear() {
    rows.clear();
    notifyListeners();
  }

  void addRow(ProductRow newRow) {
    final isAlreadyExists = rows.any(
      (oldRow) => oldRow.product.id == newRow.product.id,
    );
    if (isAlreadyExists) return;

    rows.add(newRow);
    notifyListeners();
  }

  void removeRow(ProductRow row) {
    rows.remove(row);
    notifyListeners();
  }

  void updateRow(ProductRow oldProductRow, ProductRow newProductRow) {
    final index = rows.indexOf(oldProductRow);
    rows[index] = newProductRow;
    notifyListeners();
  }
}

class _TableMediator extends InheritedNotifier<ProductTableController> {
  const _TableMediator({
    required super.child,
    required super.notifier,
  });

  static _TableMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TableMediator>()!;
  }
}

class InventoryMovementProductTable extends StatefulWidget {
  const InventoryMovementProductTable({
    super.key,
    this.controller,
    this.onAddRowAction,
    this.onRemoveRowAction,
    this.onUpdateRowAction,
    this.haveExpirationDate = true,
  });

  final ProductTableController? controller;

  final FutureOr<void> Function(ProductTableController controller)? onAddRowAction;
  final FutureOr<void> Function(ProductTableController controller, ProductRow row)? onRemoveRowAction;
  final FutureOr<void> Function(ProductTableController controller, ProductRow newRow)? onUpdateRowAction;
  final bool haveExpirationDate;

  @override
  State<InventoryMovementProductTable> createState() => _InventoryMovementProductTableState();
}

class _InventoryMovementProductTableState extends State<InventoryMovementProductTable> {
  ProductTableController? _tableController;

  @override
  void initState() {
    _tableController = widget.controller;
    _tableController ??= ProductTableController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TableNotification>(
      onNotification: (notification) {
        if (notification is AddNewRowNotification) {
          widget.onAddRowAction?.call(_tableController!);
        }
        if (notification is EntryRowDeleteNotification) {
          widget.onRemoveRowAction?.call(_tableController!, notification.productRow);
        }

        if (notification is EntryRowChangeNotification) {
          widget.onUpdateRowAction?.call(_tableController!, notification.productRow);
        }

        if (notification is EntryRowSubtotalChangedNotification) {
          _tableController?.refresh();
        }

        return true;
      },
      child: _TableMediator(
        notifier: _tableController!,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _HeaderTable(haveExpirationDate: widget.haveExpirationDate),
                const Divider(),
                const Expanded(
                  child: _InnerRows(),
                ),
                const Divider(height: 0.0),
                const _TableFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - Header

class _HeaderTable extends StatelessWidget {
  const _HeaderTable({
    required this.haveExpirationDate,
  });

  final bool haveExpirationDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Text("Nombre del Producto"),
          ),
          if (haveExpirationDate)
            const Flexible(
              fit: FlexFit.tight,
              child: Center(child: Text("F. Vencimiento")),
            ),
          const Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Cantidad")),
          ),
          const Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Costo Unitario")),
          ),
          const Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Subtotal")),
          ),
        ],
      ),
    );
  }
}

// MARK: - Footer

class _TableFooter extends StatelessWidget {
  const _TableFooter();

  @override
  Widget build(BuildContext context) {
    final mediator = _TableMediator.of(context);
    final controller = mediator.notifier!;

    final total = controller.total;

    return SizedBox(
      height: 30,
      child: Row(
        children: [
          const Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: SizedBox(),
          ),
          const Flexible(
            fit: FlexFit.tight,
            flex: 3,
            child: SizedBox(),
          ),
          const Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                "Total: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                NumberFormatter.convertToMoneyLike(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Inner Rows

class _InnerRows extends StatelessWidget {
  const _InnerRows();

  @override
  Widget build(BuildContext context) {
    final mediator = _TableMediator.of(context);
    final controller = mediator.notifier!;
    return ListView(
      children: [
        ..._generateRows(controller),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                AddNewRowNotification().dispatch(context);
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Agregar Producto",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Iterable<EntryRow> _generateRows(ProductTableController controller) sync* {
    final rows = controller.rows;
    for (var i = 0; i < rows.length; i++) {
      final currentRowModel = rows[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield EntryRow(
        key: ValueKey(currentRowModel.product),
        rowModel: currentRowModel,
        color: color,
      );
    }
  }
}

class EntryRow extends StatefulWidget {
  const EntryRow({
    super.key,
    required this.color,
    required this.rowModel,
  });

  final Color color;
  final ProductRow rowModel;

  @override
  State<EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> with AutomaticKeepAliveClientMixin {
  final expirationDateFocus = FocusNode();
  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    Future(
      () {
        if (widget.rowModel.haveExpirationDate) {
          expirationDateFocus.requestFocus();
        } else {
          focusNode.requestFocus();
        }
      },
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final product = widget.rowModel.product;

    final subtotal = (widget.rowModel.quantity * widget.rowModel.unitaryCost);
    return Ink(
      color: widget.color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 60,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Row(
              children: [
                MoreActionRowButton(widget: widget),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayProductCode(product: product),
                    Row(
                      spacing: 4,
                      children: [
                        Text(product.brandName),
                        Text(product.unitName),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.rowModel.haveExpirationDate)
            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: TextField(
                  focusNode: expirationDateFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [MonthYearInputFormatter()],
                  textAlign: TextAlign.center,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onChanged: (value) {
                    try {
                      final dateTime = DateTimeTool.fromMMYY(value);
                      widget.rowModel.expirationDate = dateTime;
                    } catch (e) {
                      widget.rowModel.expirationDate = null;
                    }
                  },
                ),
              ),
            ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: TextField(
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [IntegerTextInputFormatter()],
                textAlign: TextAlign.center,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                onChanged: (value) {
                  if (value.isEmpty) {
                    widget.rowModel.quantity = 0;
                    EntryRowSubtotalChangedNotification(widget.rowModel).dispatch(context);
                    setState(() {});
                    return;
                  }
                  final numValue = int.tryParse(value);
                  if (numValue == null) return;
                  widget.rowModel.quantity = numValue;
                  EntryRowSubtotalChangedNotification(widget.rowModel).dispatch(context);
                  setState(() {});
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Builder(
                builder: (context) {
                  final formattedCost = (widget.rowModel.unitaryCost / 100).toStringAsFixed(2);

                  if (!widget.rowModel.editableCost) {
                    return Text(formattedCost);
                  }

                  return TextFormField(
                    initialValue: formattedCost,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalTextInputFormatter()],
                    textAlign: TextAlign.center,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        widget.rowModel.unitaryCost = 0;
                        EntryRowSubtotalChangedNotification(widget.rowModel).dispatch(context);
                        setState(() {});
                        return;
                      }
                      final numValue = double.tryParse(value);
                      if (numValue == null) return;
                      final minimalUnit = (numValue * 100).round();
                      widget.rowModel.unitaryCost = minimalUnit;
                      EntryRowSubtotalChangedNotification(widget.rowModel).dispatch(context);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(NumberFormatter.convertToMoneyLike(subtotal)),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreActionRowButton extends StatelessWidget {
  const MoreActionRowButton({
    super.key,
    required this.widget,
  });

  final EntryRow widget;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          focusNode: FocusNode(skipTraversal: true),
          onPressed: () {
            final renderBox = context.findRenderObject() as RenderBox;

            final globalPosOffset = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                globalPosOffset.dx,
                globalPosOffset.dy + size.height,
                globalPosOffset.dx + size.width,
                globalPosOffset.dy + size.height,
              ),

              items: [
                PopupMenuItem(
                  child: ListTile(
                    title: const Text("Cambiar"),
                    leading: const Icon(
                      Icons.swap_horiz,
                    ),

                    onTap: () {
                      Navigator.pop(context);
                      EntryRowChangeNotification(widget.rowModel).dispatch(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: const ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("Eliminar"),
                  ),
                  onTap: () {
                    EntryRowDeleteNotification(widget.rowModel).dispatch(context);
                  },
                ),
              ],
            );
          },
          icon: const Icon(Icons.more_vert),
          splashRadius: 16,
        );
      },
    );
  }
}

// MARK: - Notifications

class TableNotification extends Notification {}

class AddNewRowNotification extends TableNotification {}

class EntryRowNotification extends TableNotification {
  final ProductRow productRow;
  EntryRowNotification(this.productRow);
}

class EntryRowDeleteNotification extends EntryRowNotification {
  EntryRowDeleteNotification(super.productRow);
}

class EntryRowChangeNotification extends EntryRowNotification {
  EntryRowChangeNotification(super.productRow);
}

class EntryRowSubtotalChangedNotification extends EntryRowNotification {
  EntryRowSubtotalChangedNotification(super.productRow);
}
