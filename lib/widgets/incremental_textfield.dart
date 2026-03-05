import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IncrementalTextField extends StatefulWidget {
  const IncrementalTextField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.minValue = 0,
    required this.maxValue,
  });

  final void Function(int value)? onChanged;
  final int? initialValue;
  final int minValue;
  final int maxValue;

  @override
  State<IncrementalTextField> createState() => _IncrementalTextFieldState();
}

class _IncrementalTextFieldState extends State<IncrementalTextField> {
  final TextEditingController _controller = TextEditingController(text: '0');
  final FocusNode _focusNode = FocusNode();
  final FocusNode _textFieldFocusNode = FocusNode();

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      bool handled = false;

      if (event.character == '+') {
        _updateValue(1);
        handled = true;
      } else if (event.character == '-') {
        _updateValue(-1);
        handled = true;
      }

      if (handled) return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _updateValue(int change) {
    final currentValue = int.tryParse(_controller.text) ?? 0;
    int newValue = currentValue + change;
    newValue = newValue.clamp(widget.minValue, widget.maxValue);
    _controller.value = TextEditingValue(
      text: newValue.toString(),
      selection: TextSelection.collapsed(offset: newValue.toString().length),
    );
    widget.onChanged?.call(newValue);
  }

  @override
  void initState() {
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue.toString();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    WidgetsBinding.instance.addPostFrameCallback((_) => _textFieldFocusNode.requestFocus());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: TextFormField(
        focusNode: _textFieldFocusNode,
        controller: _controller,
        textAlign: TextAlign.center,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        onChanged: (value) {
          int? numberValue = int.tryParse(value);
          if (numberValue == null) {
            _controller.text = '0';
            widget.onChanged?.call(0);
            setState(() {});
            return;
          }

          numberValue = numberValue.clamp(
            0,
            widget.maxValue,
          );

          _controller.value = TextEditingValue(
            text: numberValue.toString(),
            selection: TextSelection.collapsed(offset: numberValue.toString().length),
          );
          widget.onChanged?.call(numberValue);
        },
        style: const TextStyle(fontWeight: FontWeight.w500),
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
