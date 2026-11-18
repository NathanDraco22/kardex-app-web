import 'package:flutter/services.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

/// Resultado devuelto por [showDiscountInputDialog].
class DiscountInputResult {
  const DiscountInputResult({
    required this.type,
    required this.value,
  });

  /// `null` cuando el usuario quita el descuento.
  final DiscountType? type;

  /// Porcentaje entero (0..100) o monto en centavos según [type].
  final int value;

  bool get hasDiscount => type != null && value > 0;
}

/// Diálogo reutilizable para capturar un descuento por porcentaje (%) o monto fijo.
Future<DiscountInputResult?> showDiscountInputDialog(
  BuildContext context, {
  required String title,
  required int baseAmount,
  DiscountType? initialType,
  int initialValue = 0,
}) async {
  return showDialog<DiscountInputResult>(
    context: context,
    builder: (context) => _DiscountInputDialog(
      title: title,
      baseAmount: baseAmount,
      initialType: initialType,
      initialValue: initialValue,
    ),
  );
}

class _DiscountInputDialog extends StatefulWidget {
  const _DiscountInputDialog({
    required this.title,
    required this.baseAmount,
    this.initialType,
    this.initialValue = 0,
  });

  final String title;
  final int baseAmount;
  final DiscountType? initialType;
  final int initialValue;

  @override
  State<_DiscountInputDialog> createState() => _DiscountInputDialogState();
}

class _DiscountInputDialogState extends State<_DiscountInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late DiscountType _selectedType;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? DiscountType.percentage;
    final initialText = _formatInitialValue(
      _selectedType,
      widget.initialType != null ? widget.initialValue : 0,
    );
    _controller = TextEditingController(text: initialText);
  }

  String _formatInitialValue(DiscountType type, int value) {
    if (value <= 0) return '';
    if (type == DiscountType.percentage) {
      return value.clamp(0, 100).toString();
    }
    return NumberFormatter.convertFromCentsToDouble(value).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _parseCurrentValue() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return 0;
    if (_selectedType == DiscountType.percentage) {
      return int.tryParse(raw) ?? 0;
    }
    final amountDouble = double.tryParse(raw) ?? 0.0;
    return (amountDouble * 100).round();
  }

  void _onTypeChanged(DiscountType newType) {
    if (newType == _selectedType) return;
    setState(() {
      _selectedType = newType;
      _controller.clear();
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsed = _parseCurrentValue();
    if (parsed <= 0) {
      Navigator.of(context).pop(const DiscountInputResult(type: null, value: 0));
      return;
    }
    Navigator.of(context).pop(
      DiscountInputResult(type: _selectedType, value: parsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _parseCurrentValue();
    final computedDiscount = DiscountType.calculateDiscountAmount(
      type: _selectedType,
      discountValue: currentValue,
      baseAmount: widget.baseAmount,
    );
    final pctLabel = DiscountType.formatEquivalentPercentage(
      discountAmount: computedDiscount,
      baseAmount: widget.baseAmount,
    );
    final discountPreviewLabel =
        pctLabel.isNotEmpty ? 'Descuento ($pctLabel)' : 'Descuento';
    final netAmount = (widget.baseAmount - computedDiscount).clamp(0, widget.baseAmount);
    final hasInitialDiscount =
        widget.initialType != null && widget.initialValue > 0;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<DiscountType>(
                segments: const [
                  ButtonSegment(
                    value: DiscountType.percentage,
                    label: Text('Porcentaje (%)'),
                    icon: Icon(Icons.percent_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: DiscountType.amount,
                    label: Text('Monto'),
                    icon: Icon(Icons.attach_money_rounded, size: 18),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    _onTypeChanged(selection.first);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: _selectedType == DiscountType.amount,
                ),
                inputFormatters: _selectedType == DiscountType.percentage
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                decoration: InputDecoration(
                  labelText: _selectedType == DiscountType.percentage
                      ? 'Porcentaje de descuento (0 - 100)'
                      : 'Monto a descontar',
                  suffixText: _selectedType == DiscountType.percentage ? '%' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final raw = (value ?? '').trim();
                  if (raw.isEmpty) return null;
                  if (_selectedType == DiscountType.percentage) {
                    final pct = int.tryParse(raw);
                    if (pct == null || pct < 0 || pct > 100) {
                      return 'Ingresa un porcentaje entero entre 0 y 100';
                    }
                  } else {
                    final amt = double.tryParse(raw);
                    if (amt == null || amt < 0) {
                      return 'Ingresa un monto válido';
                    }
                    final cents = (amt * 100).round();
                    if (cents > widget.baseAmount) {
                      return 'No puede superar el subtotal (${NumberFormatter.convertToMoneyLike(widget.baseAmount)})';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _PreviewRow(
                      label: 'Subtotal base',
                      value: NumberFormatter.convertToMoneyLike(widget.baseAmount),
                    ),
                    const SizedBox(height: 4),
                    _PreviewRow(
                      label: discountPreviewLabel,
                      value: '-${NumberFormatter.convertToMoneyLike(computedDiscount)}',
                      valueColor: Colors.red.shade600,
                    ),
                    const Divider(height: 12),
                    _PreviewRow(
                      label: 'Total neto',
                      value: NumberFormatter.convertToMoneyLike(netAmount),
                      isBold: true,
                      valueColor: Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (hasInitialDiscount)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const DiscountInputResult(type: null, value: 0),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      color: valueColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? null : Colors.grey.shade700, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: style),
      ],
    );
  }
}

/// Chip/botón compacto reutilizable para aplicar o quitar el descuento global de factura.
/// Se oculta automáticamente cuando `useDiscounts` está desactivado en Ajustes.
class InvoiceDiscountActionChip extends StatelessWidget {
  const InvoiceDiscountActionChip({
    super.key,
    required this.itemsNetTotal,
    required this.discountType,
    required this.discountValue,
    required this.invoiceDiscountAmount,
    required this.onDiscountChanged,
    this.onClearDiscount,
  });

  final int itemsNetTotal;
  final DiscountType? discountType;
  final int discountValue;
  final int invoiceDiscountAmount;
  final void Function(DiscountType? type, int value) onDiscountChanged;
  final VoidCallback? onClearDiscount;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = invoiceDiscountAmount > 0;
    final pctLabel = discountType == DiscountType.percentage && discountValue > 0
        ? '$discountValue%'
        : DiscountType.formatEquivalentPercentage(
            discountAmount: invoiceDiscountAmount,
            baseAmount: itemsNetTotal,
          );
    final tag = pctLabel.isNotEmpty ? ' ($pctLabel)' : '';
    final label = hasDiscount
        ? 'Desc. factura$tag: -${NumberFormatter.convertToMoneyLike(invoiceDiscountAmount)}'
        : 'Desc. factura';

    return Gate(
      filters: const [DiscountsGateFilter()],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionChip(
            avatar: Icon(
              hasDiscount ? Icons.local_offer : Icons.local_offer_outlined,
              size: 16,
              color: hasDiscount ? Colors.orange.shade700 : Colors.blue.shade700,
            ),
            label: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDiscount ? FontWeight.w600 : FontWeight.w500,
                color: hasDiscount ? Colors.red.shade700 : Colors.blue.shade700,
              ),
            ),
            onPressed: itemsNetTotal <= 0
                ? null
                : () async {
                    final result = await showDiscountInputDialog(
                      context,
                      title: 'Descuento de factura',
                      baseAmount: itemsNetTotal,
                      initialType: discountType,
                      initialValue: discountValue,
                    );
                    if (result == null) return;
                    onDiscountChanged(result.type, result.value);
                  },
          ),
          if (hasDiscount && onClearDiscount != null)
            IconButton(
              tooltip: 'Quitar descuento de factura',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 16),
              onPressed: onClearDiscount,
            ),
        ],
      ),
    );
  }
}
