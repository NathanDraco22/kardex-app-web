import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

class TransferProductRow {
  TransferProductRow({
    required this.product,
    this.quantity = 0,
    this.unitaryCost = 0,
    this.expirationDate,
  });

  ProductInDbInBranch product;
  int quantity = 0;
  int unitaryCost = 0;
  DateTime? expirationDate;

  int get subTotal => (quantity * unitaryCost);
}

class TransferProductTableController extends ChangeNotifier {
  List<TransferProductRow> rows = [];

  int get total => rows.fold<int>(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );

  bool get hasRows => rows.isNotEmpty;
  int get totalRow => rows.length;

  void refresh() => notifyListeners();

  void clear() {
    rows.clear();
    notifyListeners();
  }

  void addRow(TransferProductRow newRow) {
    final isAlreadyExists = rows.any(
      (oldRow) => oldRow.product.id == newRow.product.id,
    );
    if (isAlreadyExists) return;

    rows.add(newRow);
    notifyListeners();
  }

  void removeRow(TransferProductRow row) {
    rows.remove(row);
    notifyListeners();
  }

  void updateRow(TransferProductRow oldProductRow, TransferProductRow newProductRow) {
    final index = rows.indexOf(oldProductRow);
    rows[index] = newProductRow;
    notifyListeners();
  }
}

class _TableMediator extends InheritedNotifier<TransferProductTableController> {
  const _TableMediator({
    required super.child,
    required super.notifier,
  });

  static _TableMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TableMediator>()!;
  }
}

class TransferProductTable extends StatefulWidget {
  const TransferProductTable({
    super.key,
    this.controller,
    this.onAddRowAction,
    this.onRemoveRowAction,
    this.onUpdateRowAction,
  });

  final TransferProductTableController? controller;

  final FutureOr<void> Function(TransferProductTableController controller)? onAddRowAction;
  final FutureOr<void> Function(TransferProductTableController controller, TransferProductRow row)? onRemoveRowAction;
  final FutureOr<void> Function(TransferProductTableController controller, TransferProductRow newRow)?
  onUpdateRowAction;

  @override
  State<TransferProductTable> createState() => _TransferProductTableState();
}

class _TransferProductTableState extends State<TransferProductTable> {
  TransferProductTableController? _tableController;

  @override
  void initState() {
    _tableController = widget.controller;
    _tableController ??= TransferProductTableController();
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
        child: const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                _HeaderTable(),
                Divider(),
                Expanded(
                  child: _InnerRows(),
                ),
                Divider(height: 0.0),
                _TableFooter(),
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
  const _HeaderTable();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Text("Nombre del Producto"),
          ),

          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("F. Vencimiento")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Cantidad")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Costo Unitario")),
          ),
          Flexible(
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
            flex: 3,
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

  Iterable<EntryRow> _generateRows(TransferProductTableController controller) sync* {
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
  final TransferProductRow rowModel;

  @override
  State<EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> with AutomaticKeepAliveClientMixin {
  final expirationFocus = FocusNode();
  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    Future(
      () {
        expirationFocus.requestFocus();
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
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 12,
                        ),
                        Text(
                          product.displayCode,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
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
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: TextField(
                focusNode: expirationFocus,
                inputFormatters: [MonthYearInputFormatter()],
                textAlign: TextAlign.center,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                decoration: const InputDecoration(
                  hintText: "mm/aa",
                  isDense: true,
                ),
                onChanged: (value) {
                  try {
                    final date = DateTimeTool.fromMMYY(value);
                    widget.rowModel.expirationDate = date;
                  } on Exception catch (_) {
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              child: Text(
                NumberFormatter.convertToMoneyLike(widget.rowModel.unitaryCost),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                NumberFormatter.convertToMoneyLike(subtotal),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
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
  final TransferProductRow productRow;
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
