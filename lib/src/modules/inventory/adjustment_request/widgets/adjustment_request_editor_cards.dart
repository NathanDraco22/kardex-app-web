import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/view_controller.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_item_formatters.dart';

class AdjustmentRequestEditorCards extends StatelessWidget {
  const AdjustmentRequestEditorCards({
    super.key,
    required this.viewController,
    required this.onAddProduct,
  });

  final AdjustmentRequestViewController viewController;
  final Future<void> Function() onAddProduct;

  @override
  Widget build(BuildContext context) {
    final rows = viewController.rows;

    if (rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppThemeTokens.borderRadiusLg,
          border: Border.all(color: AppThemeTokens.borderLight),
        ),
        child: Column(
          children: [
            Icon(Icons.playlist_add_rounded, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text(
              'Agrega productos para iniciar el conteo físico.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppThemeTokens.neutral),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar Producto'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          _EditorCard(
            key: ValueKey(rows[index].product.id),
            row: rows[index],
            viewController: viewController,
            index: index,
          ),
          if (index < rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

enum _CardAction { changeUnit, remove }

class _EditorCard extends StatefulWidget {
  const _EditorCard({
    super.key,
    required this.row,
    required this.viewController,
    required this.index,
  });

  final AdjustmentRequestRow row;
  final AdjustmentRequestViewController viewController;
  final int index;

  @override
  State<_EditorCard> createState() => _EditorCardState();
}

class _EditorCardState extends State<_EditorCard> {
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
  void didUpdateWidget(covariant _EditorCard oldWidget) {
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

  Future<void> _handleAction(_CardAction action) async {
    switch (action) {
      case _CardAction.changeUnit:
        final unit = await showInventoryUnitPicker(context, widget.row.product);
        if (unit == null || !mounted) return;
        widget.viewController.changeUnit(widget.row, unit);
      case _CardAction.remove:
        widget.viewController.removeRow(widget.row);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final product = row.product;
    final factor = row.safeFactor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RowColorTool.getRowColor(widget.index),
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (product.displayCode.isNotEmpty) product.displayCode,
                        if (product.brandName.isNotEmpty) product.brandName,
                      ].join(' · '),
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              ExcludeFocus(
                child: PopupMenuButton<_CardAction>(
                  tooltip: 'Acciones',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: _handleAction,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _CardAction.changeUnit,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.scale_outlined),
                        title: Text('Cambiar unidad'),
                      ),
                    ),
                    PopupMenuItem(
                      value: _CardAction.remove,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'Existencia',
                  value: '${formatAdjustmentDisplayQuantity(row.systemStock, factor)} ${row.unitName}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Costo unitario',
                  value: NumberFormatter.convertToMoneyLike(row.unitaryCost),
                  subValue: factor > 1 ? 'Base: ${NumberFormatter.convertToMoneyLike(row.baseUnitCost)}' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InputField(
                  label: 'Conteo real (${row.unitName})',
                  controller: _countController,
                  focusNode: _countFocusNode,
                  decimalDigits: 3,
                  onChanged: (value) {
                    final parsed = double.tryParse(value) ?? 0;
                    row.countedQuantity = parsed < 0 ? 0 : parsed;
                    _lastCount = row.countedQuantity;
                    widget.viewController.notifyRowChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  label: 'Diferencia',
                  value: formatAdjustmentSignedQuantity(row.difference, factor),
                  color: adjustmentDifferenceColor(row.difference),
                ),
              ),
            ],
          ),
          if (factor > 1) ...[
            const SizedBox(height: 6),
            Text(
              'Conteo base: ${row.countedBaseQuantity} ${product.unitName}',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.blue.shade700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppThemeTokens.borderLight),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppThemeTokens.neutral),
              ),
              Text(
                NumberFormatter.convertToMoneyLike(row.subtotal),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    this.subValue,
    this.color,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeTokens.surfaceLight,
        borderRadius: AppThemeTokens.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppThemeTokens.neutral),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.decimalDigits,
    this.focusNode,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int decimalDigits;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppThemeTokens.neutral),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [DecimalTextInputFormatter(decimalDigits: decimalDigits)],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
