import 'dart:math' as math;

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

int _decimalsForStep(double step) {
  const maxDecimals = 6;
  final absStep = step.abs();
  if (absStep == 0) return 0;

  for (var decimals = 0; decimals <= maxDecimals; decimals++) {
    final scaled = absStep * math.pow(10, decimals);
    if ((scaled - scaled.roundToDouble()).abs() < 1e-7) {
      return decimals;
    }
  }
  return maxDecimals;
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
    this.step,
    this.showButtons = false,
    this.showTitle = false,
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
  final double? step;
  final bool showButtons;
  final bool showTitle;
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
  static const double _comparisonTolerance = 1e-6;

  late TextEditingController _controller;
  bool _ownsController = false;

  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  String? _stepError;

  double get _effectiveStep => widget.step ?? UnitConversionTool.minimumStep(widget.conversionFactor);

  int get _maxDecimals => _decimalsForStep(_effectiveStep);

  /// Tolerancia en unidades base equivalente al error máximo de redondeo del
  /// texto formateado. Para pasos como `1/30` el texto solo conserva 6
  /// decimales, así que validar con `1e-6` en base marcaría como inválido un
  /// valor generado por el propio campo.
  double get _validationTolerance {
    final factor = UnitConversionTool.ensureSafeFactor(widget.conversionFactor);
    final roundingError = math.pow(10, -_maxDecimals).toDouble() * factor / 2;
    return math.max(_comparisonTolerance, roundingError);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownsController = true;
      final initial = widget.initialValue ?? 0.0;
      _controller = TextEditingController(
        text: initial == 0.0
            ? ''
            : UnitConversionTool.formatQuantity(
                initial,
                maxDecimals: _maxDecimals,
              ),
      );
    }
    _attachFocusNode();
  }

  void _attachFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant QuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller!;
      _ownsController = false;
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _attachFocusNode();
    }

    if (widget.step != oldWidget.step ||
        widget.conversionFactor != oldWidget.conversionFactor ||
        widget.allowDecimals != oldWidget.allowDecimals) {
      _stepError = null;
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
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
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

  /// Valor que resultaría de avanzar/retroceder un paso.
  ///
  /// Sin paso explícito y con factor > 1 se opera en unidades base enteras
  /// para que la secuencia no acumule deriva (p. ej. factor 30 debe llegar a
  /// `1`, nunca a `0.99999`).
  double _stepValue(double current, int direction) {
    final factor = UnitConversionTool.ensureSafeFactor(widget.conversionFactor);
    if (widget.step == null && factor > 1) {
      final currentBase = (current * factor).round();
      final nextBase = currentBase + direction;
      return nextBase / factor;
    }
    return current + direction * _effectiveStep;
  }

  String _stepErrorMessage() {
    if (_maxDecimals >= 6) {
      return 'Cantidad fuera de la fracción mínima';
    }
    final stepText = UnitConversionTool.formatQuantity(
      _effectiveStep,
      maxDecimals: _maxDecimals,
    );
    return 'Debe ser múltiplo de $stepText';
  }

  /// Valida que la cantidad escrita sea un múltiplo exacto de una unidad base.
  String? _validateStep(String? value) {
    if (widget.readOnly || !widget.isDecimalSupported) return null;

    final text = (value ?? _controller.text).trim().replaceAll(',', '.');
    if (text.isEmpty) return null;

    final parsed = double.tryParse(text);
    if (parsed == null || !parsed.isFinite || parsed == 0) return null;

    final factor = UnitConversionTool.ensureSafeFactor(widget.conversionFactor);
    final scaled = parsed * factor;
    final nearest = scaled.roundToDouble();
    if ((scaled - nearest).abs() > _validationTolerance) {
      return _stepErrorMessage();
    }
    return null;
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    _validateAndShowError();
  }

  void _validateAndShowError() {
    if (!mounted) return;
    final error = _validateStep(_controller.text);
    if (error == _stepError) return;
    setState(() => _stepError = error);
  }

  String? _combinedValidator(String? value) {
    final external = widget.validator?.call(value);
    if (external != null) return external;
    return _validateStep(value);
  }

  void _updateValue(double newValue) {
    var clamped = newValue;
    if (clamped < widget.min - _comparisonTolerance) clamped = widget.min;
    if (widget.max != null && clamped > widget.max! + _comparisonTolerance) {
      clamped = widget.max!;
    }

    if (!widget.isDecimalSupported) {
      clamped = clamped.roundToDouble();
      final max = widget.max;
      if (max != null && clamped > max) {
        clamped = max.floorToDouble();
      }
      if (clamped < widget.min) {
        clamped = widget.min.ceilToDouble();
      }
    }

    final formatted = clamped == 0.0 && widget.min == 0.0
        ? ''
        : UnitConversionTool.formatQuantity(
            clamped,
            maxDecimals: _maxDecimals,
          );

    _controller.text = formatted;
    _controller.selection = TextSelection.collapsed(offset: formatted.length);
    widget.onChanged(clamped);
    if (mounted) setState(() {});
  }

  void _increment() {
    if (widget.readOnly) return;
    final current = _parseCurrentValue();
    _updateValue(_stepValue(current, 1));
  }

  void _decrement() {
    if (widget.readOnly) return;
    final current = _parseCurrentValue();
    _updateValue(_stepValue(current, -1));
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.readOnly) return KeyEventResult.ignored;
    if (event is KeyDownEvent) {
      if (event.character == '+' || event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        _increment();
        return KeyEventResult.handled;
      } else if (event.character == '-' || event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        _decrement();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final canUseDecimals = widget.isDecimalSupported;

    final keyboardType = canUseDecimals ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number;

    final inputFormatters = canUseDecimals
        ? [DecimalQuantityTextInputFormatter(maxDecimalDigits: _maxDecimals)]
        : [FilteringTextInputFormatter.digitsOnly];

    final currentVal = _parseCurrentValue();
    final canDecrement = _stepValue(currentVal, -1) >= widget.min - _comparisonTolerance;
    final canIncrement = widget.max == null || _stepValue(currentVal, 1) <= widget.max! + _comparisonTolerance;
    final showEquivalence =
        canUseDecimals && widget.baseUnitName != null && widget.baseUnitName!.isNotEmpty && currentVal > 0;
    final baseQty = (currentVal * widget.conversionFactor).round();

    final textField = TextFormField(
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      controller: _controller,
      textAlign: widget.titleTextAlign ?? TextAlign.center,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.w600),
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        suffixText: widget.unitLabel,
        isDense: true,
        errorText: _stepError,
      ),
      onEditingComplete: widget.onEditingComplete == null
          ? null
          : () {
              _validateAndShowError();
              widget.onEditingComplete!();
            },
      validator: _combinedValidator,
      onChanged: (val) {
        if (_stepError != null) {
          _stepError = null;
        }
        final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
        if (widget.max != null && parsed > widget.max! + _comparisonTolerance) {
          _updateValue(widget.max!);
          return;
        }
        if (parsed < widget.min - _comparisonTolerance) {
          _updateValue(widget.min);
          return;
        }
        widget.onChanged(parsed);
        if (mounted) setState(() {});
      },
    );

    final stepper = widget.showButtons
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: canDecrement ? _decrement : null,
                visualDensity: VisualDensity.compact,
                color: Colors.red.shade600,
              ),
              Expanded(child: textField),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: canIncrement ? _increment : null,
                visualDensity: VisualDensity.compact,
                color: Colors.green.shade600,
              ),
            ],
          )
        : textField;

    final content = Focus(
      canRequestFocus: false,
      onKeyEvent: _handleKeyEvent,
      child: stepper,
    );

    final hasVisibleTitle = widget.showTitle && widget.title != null;

    if (!hasVisibleTitle && !showEquivalence) {
      return content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasVisibleTitle) ...[
          Row(
            mainAxisAlignment: widget.centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
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
