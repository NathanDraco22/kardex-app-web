import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/calculator/numpad.dart';

class CalculatorField extends StatefulWidget {
  const CalculatorField({super.key, this.initialValue, this.onDone});

  final String? initialValue;
  final void Function(String value)? onDone;

  @override
  State<CalculatorField> createState() => _CalculatorFieldState();
}

class _CalculatorFieldState extends State<CalculatorField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '0.00');
  }

  Future<void> _openCalculator() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) {
        return NumpadCalculator(initialValue: _controller.text);
      },
    );
    if (result != null) {
      setState(() {
        _controller.text = result.toStringAsFixed(2);
        widget.onDone?.call(result.toStringAsFixed(2));
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: _openCalculator,
      textAlign: TextAlign.center,
    );
  }
}
