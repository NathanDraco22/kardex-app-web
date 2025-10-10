import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/calculator/numpad.dart';

class CalculatorField extends StatefulWidget {
  const CalculatorField({super.key});

  @override
  State<CalculatorField> createState() => _CalculatorFieldState();
}

class _CalculatorFieldState extends State<CalculatorField> {
  final TextEditingController _controller = TextEditingController(text: '0.00');

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
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        labelText: 'Monto',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calculate),
      ),
    );
  }
}
