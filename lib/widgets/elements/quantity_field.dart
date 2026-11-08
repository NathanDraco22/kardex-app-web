import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_business/kardex_business.dart';

class DecimalQuantityTextInputFormatter extends TextInputFormatter {
  final int maxDecimalDigits;

  DecimalQuantityTextInputFormatter({this.maxDecimalDigits = 3});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Normalizar coma a punto
    String text = newValue.text.replaceAll(',', '.');

    // Permitir solo números y como máximo un punto decimal con hasta maxDecimalDigits decimales
    final regExp = RegExp('^\\d*\\.?\\d{0,$maxDecimalDigits}\$');
    if (!regExp.hasMatch(text)) {
      return oldValue;
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class QuantityField extends StatefulWidget {
  const QuantityField({
    super.key,
    this.initialValue,
    this.conversionFactor = 1,
    this.allowDecimals = true,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.validator,
    this.min = 0.0,
    this.max,
    this.step = 1.0,
    this.showButtons = false,
    this.unitLabel,
    this.baseUnitName,
    this.title = "Cantidad",
    this.centerTitle = false,
    this.titleTextAlign,
    this.style,
    this.decoration,
    this.autofocus = false,
    this.readOnly = false,
  });

  final double? initialValue;
  final int conversionFactor;
  final bool allowDecimals;
  final ValueChanged<double> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final double min;
  final double? max;
  final double step;
  final bool showButtons;
  final String? unitLabel;
  final String? baseUnitName;
  final String? title;
  final bool centerTitle;
  final TextAlign? titleTextAlign;
  final TextStyle? style;
  final InputDecoration? decoration;
  final bool autofocus;
  final bool readOnly;

  bool get isDecimalSupported => conversionFactor > 1 && allowDecimals;

  @override
  State<QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<QuantityField> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownsController = true;
      final initial = widget.initialValue ?? 0.0;
      _controller = TextEditingController(
        text: initial == 0.0 ? '' : UnitConversionTool.formatQuantity(initial),
      );
    }
  }

  @override
  void didUpdateWidget(covariant QuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller!;
      _ownsController = false;
    }

    // Si cambió el factor de conversión o allowDecimals y ya no soporta decimales, normalizar
    if (!widget.isDecimalSupported && oldWidget.isDecimalSupported) {
      final currentNum = double.tryParse(_controller.text) ?? 0.0;
      if (currentNum != currentNum.roundToDouble()) {
        final rounded = currentNum.roundToDouble();
        _controller.text = rounded == 0.0 ? '' : rounded.toInt().toString();
        widget.onChanged(rounded);
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  double _parseCurrentValue() {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  void _updateValue(double newValue) {
    var clamped = newValue;
    if (clamped < widget.min) clamped = widget.min;
    if (widget.max != null && clamped > widget.max!) clamped = widget.max!;

    if (!widget.isDecimalSupported) {
      clamped = clamped.roundToDouble();
    }

    final formatted = clamped == 0.0 && widget.min == 0.0
        ? ''
        : UnitConversionTool.formatQuantity(clamped);

    _controller.text = formatted;
    _controller.selection = TextSelection.collapsed(offset: formatted.length);
    widget.onChanged(clamped);
  }

  void _increment() {
    final current = _parseCurrentValue();
    _updateValue(current + widget.step);
  }

  void _decrement() {
    final current = _parseCurrentValue();
    _updateValue(current - widget.step);
  }

  @override
  Widget build(BuildContext context) {
    final canUseDecimals = widget.isDecimalSupported;

    final keyboardType = canUseDecimals
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number;

    final inputFormatters = canUseDecimals
        ? [DecimalQuantityTextInputFormatter(maxDecimalDigits: 3)]
        : [FilteringTextInputFormatter.digitsOnly];

    final currentVal = _parseCurrentValue();
    final showEquivalence = canUseDecimals &&
        widget.baseUnitName != null &&
        widget.baseUnitName!.isNotEmpty &&
        currentVal > 0;
    final baseQty = (currentVal * widget.conversionFactor).round();

    final textField = TextFormField(
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      controller: _controller,
      textAlign: widget.titleTextAlign ?? TextAlign.center,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.w600),
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        suffixText: widget.unitLabel,
        isDense: true,
      ),
      onEditingComplete: widget.onEditingComplete,
      validator: widget.validator,
      onChanged: (val) {
        final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
        widget.onChanged(parsed);
        if (showEquivalence) setState(() {});
      },
    );

    Widget content;
    if (widget.showButtons) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: currentVal <= widget.min ? null : _decrement,
            visualDensity: VisualDensity.compact,
            color: Colors.red.shade600,
          ),
          Expanded(child: textField),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: (widget.max != null && currentVal >= widget.max!)
                ? null
                : _increment,
            visualDensity: VisualDensity.compact,
            color: Colors.green.shade600,
          ),
        ],
      );
    } else {
      content = textField;
    }

    if (widget.title == null && !showEquivalence) {
      return content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null) ...[
          Row(
            mainAxisAlignment: widget.centerTitle
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Text(
                widget.title!,
                textAlign: widget.titleTextAlign,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (widget.unitLabel != null) ...[
                const SizedBox(width: 4),
                Text(
                  "(${widget.unitLabel})",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        content,
        if (showEquivalence) ...[
          const SizedBox(height: 2),
          Text(
            "= $baseQty ${widget.baseUnitName}",
            textAlign: widget.titleTextAlign ?? TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
