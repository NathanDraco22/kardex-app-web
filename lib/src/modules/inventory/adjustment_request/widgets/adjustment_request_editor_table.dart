import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/view_controller.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_item_formatters.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

class AdjustmentRequestEditorTable extends StatelessWidget {
  const AdjustmentRequestEditorTable({
    super.key,
    required this.viewController,
    required this.onAddProduct,
  });

  final AdjustmentRequestViewController viewController;
  final Future<void> Function() onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const _HeaderTable(),
            const Divider(),
            Expanded(
              child: _InnerRows(
                viewController: viewController,
                onAddProduct: onAddProduct,
              ),
            ),
            const Divider(height: 0.0),
            _TableFooter(viewController: viewController),
          ],
        ),
      ),
    );
  }
}

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
            child: Text('Nombre del Producto'),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text('Existencia')),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text('Conteo Real')),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text('Diferencia')),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text('Costo Unitario')),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text('Subtotal')),
          ),
        ],
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({required this.viewController});

  final AdjustmentRequestViewController viewController;

  @override
  Widget build(BuildContext context) {
    final surplus = viewController.totalSurplus;
    final shortage = viewController.totalShortage;
    final netTotal = viewController.netTotal;

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Text(
            'Productos: ${viewController.productCount}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          const Text(
            'Sobrante: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(surplus),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Faltante: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(shortage),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 24),
          const Text(
            'Total Neto: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(netTotal),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _InnerRows extends StatelessWidget {
  const _InnerRows({
    required this.viewController,
    required this.onAddProduct,
  });

  final AdjustmentRequestViewController viewController;
  final Future<void> Function() onAddProduct;

  @override
  Widget build(BuildContext context) {
    final rows = viewController.rows;

    return ListView(
      children: [
        for (var i = 0; i < rows.length; i++)
          _EditorRow(
            key: ValueKey(rows[i].product.id),
            row: rows[i],
            viewController: viewController,
            color: RowColorTool.getRowColor(i),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedCtrlButton(
              hotKey: '1',
              autofocus: rows.isEmpty,
              onPressed: onAddProduct,
              icon: Icons.add,
              label: 'Agregar Producto',
            ),
          ],
        ),
      ],
    );
  }
}

enum _RowAction { changeUnit, remove }

class _EditorRow extends StatefulWidget {
  const _EditorRow({
    super.key,
    required this.row,
    required this.viewController,
    required this.color,
  });

  final AdjustmentRequestRow row;
  final AdjustmentRequestViewController viewController;
  final Color color;

  @override
  State<_EditorRow> createState() => _EditorRowState();
}

class _EditorRowState extends State<_EditorRow> {
  late final TextEditingController _countController;
  final FocusNode _countFocusNode = FocusNode();

  double _lastCount = 0;
  int _lastFactor = 1;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.row.countedQuantity;
    _lastFactor = widget.row.conversionFactor;
    _countController = TextEditingController(
      text: UnitConversionTool.formatQuantity(widget.row.countedQuantity),
    );

    Future(() {
      if (!mounted) return;
      _countFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _EditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final row = widget.row;

    if (_lastFactor != row.conversionFactor || _lastCount != row.countedQuantity) {
      _lastFactor = row.conversionFactor;
      _lastCount = row.countedQuantity;
      _countController.text = UnitConversionTool.formatQuantity(row.countedQuantity);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _countFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAction(_RowAction action) async {
    switch (action) {
      case _RowAction.changeUnit:
        final unit = await showInventoryUnitPicker(context, widget.row.product);
        if (unit == null || !mounted) return;
        widget.viewController.changeUnit(widget.row, unit);
      case _RowAction.remove:
        widget.viewController.removeRow(widget.row);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final product = row.product;
    final factor = row.safeFactor;

    return Ink(
      color: widget.color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 75,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Row(
              children: [
                ExcludeFocus(
                  child: PopupMenuButton<_RowAction>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Opciones',
                    onSelected: _handleAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _RowAction.changeUnit,
                        child: Row(
                          children: [
                            Icon(Icons.sync_alt, size: 20),
                            SizedBox(width: 8),
                            Text('Cambiar Unidad'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _RowAction.remove,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text('Eliminar fila', style: TextStyle(color: Colors.red.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DisplayProductCode(product: product),
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              product.brandName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final label = row.unitName;
                              Color? color;
                              if (row.selectedUnitIndex > 0) {
                                color = Colors.blue.shade700;
                              }
                              return Text(
                                label,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: row.selectedUnitIndex > 0 ? FontWeight.w600 : null,
                                ),
                              );
                            },
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatAdjustmentDisplayQuantity(row.systemStock, factor),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    row.unitName,
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _countController,
                    focusNode: _countFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [DecimalTextInputFormatter(decimalDigits: 3)],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onChanged: (value) {
                      final parsed = double.tryParse(value) ?? 0;
                      if (parsed < 0) {
                        _countController.text = '0';
                        _countController.selection = const TextSelection.collapsed(offset: 1);
                        row.countedQuantity = 0;
                      } else {
                        row.countedQuantity = parsed;
                      }
                      _lastCount = row.countedQuantity;
                      widget.viewController.notifyRowChanged();
                      setState(() {});
                    },
                  ),
                  if (factor > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      '= ${row.countedBaseQuantity} ${product.unitName}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    adjustmentDifferenceIcon(row.difference),
                    size: 16,
                    color: adjustmentDifferenceColor(row.difference),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      formatAdjustmentSignedQuantity(row.difference, factor),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: adjustmentDifferenceColor(row.difference),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    NumberFormatter.convertToMoneyLike(row.unitaryCost),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (factor > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Base: ${NumberFormatter.convertToMoneyLike(row.baseUnitCost)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                NumberFormatter.convertToMoneyLike(row.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
