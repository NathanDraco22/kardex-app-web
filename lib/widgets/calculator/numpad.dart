import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class NumpadCalculator extends StatefulWidget {
  const NumpadCalculator({super.key, this.initialValue = '0'});

  final String initialValue;

  @override
  State<NumpadCalculator> createState() => _NumpadCalculatorState();
}

class _NumpadCalculatorState extends State<NumpadCalculator> {
  String _expression = '';
  String _previousExpression = '';
  bool _isResultShown = false;

  final NumberFormat _formatter = NumberFormat()
    ..maximumFractionDigits = 4
    ..minimumFractionDigits = 0;

  @override
  Widget build(BuildContext context) {
    final isOperation = _expression.contains(RegExp(r'(?<!^)[+\-*/]'));
    return SafeArea(
      child: Container(
        height: 450,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _previousExpression,
                    style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                    maxLines: 1,
                  ),
                  Text(
                    _expression.isEmpty ? '0' : _expression,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildButton('C', onPressed: _onClear, color: Colors.red),
                _buildButton('⌫', onPressed: _onBackspace),
                _buildButton('%'),
                _buildButton('/'),
              ],
            ),
            Row(
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('*'),
              ],
            ),
            Row(
              children: [
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('-'),
              ],
            ),
            Row(
              children: [
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('+'),
              ],
            ),
            Row(
              children: [
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('=', onPressed: _calculate),
                _buildDoneButton(
                  '✓',
                  onPressed: isOperation ? null : _onDone,
                  color: isOperation ? Colors.grey : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDone() {
    if (_expression.isEmpty) {
      Navigator.of(context).pop(0.0);
      return;
    }
    _calculate();
    final valueToReturn = num.tryParse(_expression.replaceAll(',', '')) ?? 0.0;
    Navigator.of(context).pop(valueToReturn.toDouble());
  }

  Widget _buildButton(String text, {VoidCallback? onPressed, Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTapUp: (details) {
          if (onPressed == null) {
            _onButtonPressed(text);
          } else {
            onPressed.call();
          }
        },
        child: Ink(
          width: 120,
          height: 60,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
    // return Expanded(
    //   flex: flex,
    //   child: TextButton(
    //     style: TextButton.styleFrom(
    //       foregroundColor: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    //       padding: const EdgeInsets.symmetric(vertical: 16),
    //     ),
    //     onPressed: onPressed ?? () => _onButtonPressed(text),
    //     child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
    //   ),
    // );
  }

  Widget _buildDoneButton(String text, {VoidCallback? onPressed, Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTapUp: (details) {
          if (onPressed == null) {
            _onButtonPressed(text);
          } else {
            onPressed.call();
          }
        },
        child: Ink(
          width: 120,
          height: 50,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
    // return Expanded(
    //   flex: flex,
    //   child: TextButton(
    //     style: TextButton.styleFrom(
    //       foregroundColor: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    //       padding: const EdgeInsets.symmetric(vertical: 16),
    //     ),
    //     onPressed: onPressed,
    //     child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
    //   ),
    // );
  }

  void _onButtonPressed(String char) {
    setState(() {
      if (_isResultShown && (RegExp(r'[0-9]').hasMatch(char) || char == '.')) {
        _expression = '';
        _previousExpression = '';
      }
      _isResultShown = false;
      _expression += char;
    });
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _previousExpression = '';
      _isResultShown = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _isResultShown = false;
    });
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    String expressionToParse = _expression.replaceAll(",", "");
    num result;

    try {
      final percentageRegex = RegExp(r'^(\d+\.?\d*)\s*([+\-])\s*(\d+\.?\d*)%$');
      final match = percentageRegex.firstMatch(expressionToParse);

      if (match != null) {
        final baseNumber = double.parse(match.group(1)!);
        final operator = match.group(2)!;
        final percentage = double.parse(match.group(3)!);
        final percentValue = baseNumber * (percentage / 100);
        result = (operator == '+') ? baseNumber + percentValue : baseNumber - percentValue;
      } else {
        final parser = GrammarParser();
        final expression = parser.parse(expressionToParse);
        result = RealEvaluator(ContextModel()).evaluate(expression);
      }

      setState(() {
        _previousExpression = '$_expression =';
        _expression = _formatter.format(result);
        _isResultShown = true;
      });
    } catch (e) {
      log("Expresión inválida: $e");
    }
  }
}
