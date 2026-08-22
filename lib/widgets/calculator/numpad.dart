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
    ..maximumFractionDigits = 2
    ..minimumFractionDigits = 0;

  @override
  void initState() {
    super.initState();
    final cleanInit = widget.initialValue.replaceAll(',', '').trim();
    if (cleanInit.isNotEmpty && cleanInit != '0' && cleanInit != '0.0' && cleanInit != '0.00') {
      _expression = cleanInit;
      _isResultShown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 26, color: Colors.grey.shade600),
                    maxLines: 1,
                  ),
                  Text(
                    _expression.isEmpty ? '0' : _expression,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                _buildDoneButton(
                  '✓',
                  onPressed: _onDone,
                  color: Colors.green,
                  flex: 2,
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
      final cleanInit = widget.initialValue.replaceAll(',', '').trim();
      final parsed = double.tryParse(cleanInit) ?? 0.0;
      Navigator.of(context).pop(parsed);
      return;
    }
    
    // Si contiene algún operador pendiente, actúa como "=" evaluando la expresión
    final hasOperators = _expression.contains(RegExp(r'(?<!^)[+\-*/%]'));
    if (hasOperators) {
      _calculate();
    } else {
      final valueToReturn = num.tryParse(_expression.replaceAll(',', '')) ?? 0.0;
      Navigator.of(context).pop(valueToReturn.toDouble());
    }
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
          width: double.infinity,
          height: 55,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: color,
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
          width: double.infinity,
          height: 55,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.green,
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

  String _preprocessPercentage(String input) {
    String s = input;
    int index;
    while ((index = s.indexOf('%')) != -1) {
      int j = index - 1;
      while (j >= 0 && s[j] == ' ') {
        j--;
      }
      if (j < 0) {
        s = s.replaceRange(index, index + 1, '/100');
        continue;
      }
      int endY = j + 1;
      int startY;
      if (s[j] == ')') {
        int pCount = 1;
        j--;
        while (j >= 0 && pCount > 0) {
          if (s[j] == ')') pCount++;
          if (s[j] == '(') pCount--;
          if (pCount > 0) j--;
        }
        if (j < 0) {
          s = s.replaceRange(index, index + 1, '/100');
          continue;
        }
        startY = j;
      } else {
        while (j >= 0 && (RegExp(r'[0-9.]').hasMatch(s[j]))) {
          j--;
        }
        startY = j + 1;
      }
      final String Y = s.substring(startY, endY);
      int k = startY - 1;
      while (k >= 0 && s[k] == ' ') {
        k--;
      }
      if (k < 0) {
        s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
      } else {
        final String op = s[k];
        if (op == '+' || op == '-' || op == '*' || op == '/') {
          int startX = 0;
          int pCount = 0;
          for (int m = k - 1; m >= 0; m--) {
            if (s[m] == ')') {
              pCount++;
            } else if (s[m] == '(') {
              if (pCount == 0) {
                startX = m + 1;
                break;
              } else {
                pCount--;
              }
            }
          }
          final String X = s.substring(startX, k).trim();
          if (X.isEmpty) {
            s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
          } else {
            String replacement;
            if (op == '+' || op == '-') {
              replacement = '(($X) $op (($X) * ($Y) / 100))';
            } else {
              replacement = '($X $op (($Y) / 100))';
            }
            s = s.replaceRange(startX, index + 1, replacement);
          }
        } else {
          s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
        }
      }
    }
    return s;
  }

  /// Limpia las comas de forma inteligente:
  /// - Si la coma está seguida por exactamente 3 dígitos (ej. miles en 15,000), se remueve.
  /// - En cualquier otro caso (ej. 15,5), se reemplaza por punto decimal.
  String _cleanCommas(String input) {
    final RegExp thousandRegExp = RegExp(r',(\d{3})(?!\d)');
    String result = input.replaceAllMapped(thousandRegExp, (match) {
      return match.group(1)!;
    });
    return result.replaceAll(',', '.');
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    String expressionToParse = _cleanCommas(_expression);
    num result;

    try {
      // Preprocesar los porcentajes comerciales
      expressionToParse = _preprocessPercentage(expressionToParse);

      final parser = GrammarParser();
      final expression = parser.parse(expressionToParse);
      result = RealEvaluator(ContextModel()).evaluate(expression);

      if (result.isInfinite || result.isNaN) {
        throw Exception("Resultado no definido");
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
