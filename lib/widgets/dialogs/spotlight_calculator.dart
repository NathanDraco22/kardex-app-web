import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

/// Diálogo flotante interactivo tipo macOS Spotlight que funciona como calculadora en tiempo real.
class SpotlightCalculator extends StatefulWidget {
  const SpotlightCalculator({super.key});

  @override
  State<SpotlightCalculator> createState() => _SpotlightCalculatorState();
}

class _SpotlightCalculatorState extends State<SpotlightCalculator> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _resultText = '';
  double? _numericResult;
  bool _isValidExpression = false;

  final NumberFormat _formatter = NumberFormat()
    ..maximumFractionDigits = 2
    ..minimumFractionDigits = 0;

  @override
  void initState() {
    super.initState();
    // Solicitar foco al inicializar el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Evalúa la expresión matemática en tiempo real.
  /// Implementa la lógica de porcentaje comercial:
  /// - X +/- Y% => X +/- (X * Y / 100)
  /// - X * Y% => X * (Y / 100)
  /// - X / Y% => X / (Y / 100)
  /// - Y% => Y / 100
  void _evaluateExpression(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _resultText = '';
        _numericResult = null;
        _isValidExpression = false;
      });
      return;
    }

    try {
      // 1. Limpiar comas de forma inteligente (miles vs decimales)
      String expressionToParse = _cleanCommas(value);

      // 2. Preprocesar los porcentajes comerciales
      expressionToParse = _preprocessPercentage(expressionToParse);

      // 3. Limpiar espacios extra y parsear con math_expressions
      final parser = GrammarParser();
      final exp = parser.parse(expressionToParse);
      final cm = ContextModel();
      final result = RealEvaluator(cm).evaluate(exp);

      if (result.isInfinite || result.isNaN) {
        throw Exception("Resultado no definido");
      }

      setState(() {
        _numericResult = result.toDouble();
        _resultText = _formatter.format(result);
        _isValidExpression = true;
      });
    } catch (e) {
      // Guardar el error internamente pero no interrumpir la escritura del usuario.
      // Se mantiene el estado de expresión inválida para que la UI reaccione correspondientemente.
      setState(() {
        _isValidExpression = false;
      });
    }
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

  /// Algoritmo de preprocesamiento de porcentaje comercial.
  /// Escanea la cadena de izquierda a derecha buscando símbolos '%' y los reemplaza
  /// de forma contextual en base al operando y la expresión previa a su izquierda.
  String _preprocessPercentage(String input) {
    String s = input;
    int index;

    // Iteramos mientras existan símbolos '%'
    while ((index = s.indexOf('%')) != -1) {
      int j = index - 1;

      // Omitir espacios en blanco a la izquierda del '%'
      while (j >= 0 && s[j] == ' ') {
        j--;
      }

      if (j < 0) {
        // Un % al inicio de la cadena no es válido comercialmente.
        // Lo reemplazamos por '/100' para evitar bucle infinito y dejar que el parser lance error si es el caso.
        s = s.replaceRange(index, index + 1, '/100');
        continue;
      }

      int endY = j + 1;
      int startY;

      if (s[j] == ')') {
        // Si el operando izquierdo es un bloque agrupado por paréntesis, buscamos su pareja abierta '('
        int pCount = 1;
        j--;
        while (j >= 0 && pCount > 0) {
          if (s[j] == ')') pCount++;
          if (s[j] == '(') pCount--;
          if (pCount > 0) j--;
        }
        if (j < 0) {
          // Paréntesis desbalanceados
          s = s.replaceRange(index, index + 1, '/100');
          continue;
        }
        startY = j;
      } else {
        // Es un operando numérico. Escaneamos hacia atrás dígitos y punto decimal.
        while (j >= 0 && (RegExp(r'[0-9.]').hasMatch(s[j]))) {
          j--;
        }
        startY = j + 1;
      }

      final String Y = s.substring(startY, endY);

      // Buscar el operador que antecede al operando Y
      int k = startY - 1;
      while (k >= 0 && s[k] == ' ') {
        k--;
      }

      if (k < 0) {
        // No hay ningún operador a la izquierda (ej. "10%").
        // Se evalúa como un porcentaje aislado: Y / 100
        s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
      } else {
        final String op = s[k];
        if (op == '+' || op == '-' || op == '*' || op == '/') {
          // Encontrar el inicio de la expresión X a la izquierda del operador.
          // Se limita por el nivel de paréntesis para no romper la precedencia de grupos superiores.
          int startX = 0;
          int pCount = 0;
          for (int m = k - 1; m >= 0; m--) {
            if (s[m] == ')') {
              pCount++;
            } else if (s[m] == '(') {
              if (pCount == 0) {
                // Paréntesis abierto que pertenece a un nivel superior, detenemos el escaneo de X aquí.
                startX = m + 1;
                break;
              } else {
                pCount--;
              }
            }
          }

          final String X = s.substring(startX, k).trim();
          if (X.isEmpty) {
            // Operador solitario antes del porcentaje (ej. "- 10%")
            s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
          } else {
            String replacement;
            if (op == '+' || op == '-') {
              // Comportamiento comercial: X +/- (X * Y / 100)
              replacement = '(($X) $op (($X) * ($Y) / 100))';
            } else {
              // Comportamiento comercial: X * (Y / 100) o X / (Y / 100)
              replacement = '($X $op (($Y) / 100))';
            }
            s = s.replaceRange(startX, index + 1, replacement);
          }
        } else {
          // No es un operador aritmético válido antecedente
          s = s.replaceRange(startY, index + 1, '(($Y) / 100)');
        }
      }
    }

    return s;
  }

  /// Copia el resultado al portapapeles y cierra el diálogo.
  void _copyToClipboardAndClose() {
    if (!_isValidExpression || _resultText.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _resultText))
        .then((_) {
          if (mounted) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              title: const Text('Resultado copiado'),
              description: Text('Se copió "$_resultText" al portapapeles.'),
              autoCloseDuration: const Duration(seconds: 2),
              style: ToastificationStyle.flatColored,
            );
            Navigator.of(context).pop(_numericResult);
          }
        })
        .catchError((e) {
          log('Error al copiar al portapapeles: $e');
        });
  }

  /// Maneja la confirmación (Enter / Submit).
  /// - Si la entrada contiene una operación por resolver, evalúa y coloca el resultado en el campo de texto.
  /// - Si la entrada ya es igual al resultado (o es un número simple), copia al portapapeles y cierra.
  void _handleSubmitted() {
    if (!_isValidExpression || _resultText.isEmpty) return;

    final currentText = _controller.text.trim();
    final cleanResult = _resultText.trim();

    if (currentText != cleanResult) {
      setState(() {
        _controller.text = cleanResult;
        // Mover el cursor al final de la expresión
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cleanResult.length),
        );
        // Volver a evaluar el nuevo valor (que ahora es el número plano)
        _evaluateExpression(cleanResult);
      });

      // Solicitar el foco explícitamente y asegurar que el cursor quede al final (con un retraso breve para anular la selección por defecto del foco)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        Future.delayed(const Duration(milliseconds: 30), () {
          if (mounted) {
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          }
        });
      });
    } else {
      // Si la entrada ya es igual al resultado, copiar y cerrar
      _copyToClipboardAndClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores premium con transparencia para el estilo macOS Spotlight
    final backgroundColor = isDark
        ? const Color(0xFF1E1E1E).withValues(alpha: 0.75)
        : const Color(0xFFF5F5F7).withValues(alpha: 0.85);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            shadowColor: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Fila de Entrada de la calculadora
                      Row(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 28,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Escribe una expresión (ej. 100 - 10%)',
                                hintStyle: TextStyle(color: hintColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              ),
                              cursorColor: theme.colorScheme.primary,
                              onChanged: _evaluateExpression,
                              onSubmitted: (_) => _handleSubmitted(),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _controller.clear();
                                _evaluateExpression('');
                                _focusNode.requestFocus();
                              },
                              color: hintColor,
                            ),
                        ],
                      ),
                      // Sección del resultado si hay texto
                      AnimatedSize(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        child: _controller.text.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  Divider(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05),
                                    height: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Indicaciones o ayuda en la esquina inferior izquierda
                                      Opacity(
                                        opacity: _isValidExpression ? 0.6 : 0.4,
                                        child: Text(
                                          _isValidExpression
                                              ? (_controller.text.trim() == _resultText.trim()
                                                    ? 'Presiona Enter para copiar'
                                                    : 'Presiona Enter para calcular')
                                              : (_controller.text.trim().isEmpty ? '' : 'Expresión incompleta...'),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      // Resultado a la derecha
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _isValidExpression ? _resultText : '—',
                                            style: theme.textTheme.headlineMedium?.copyWith(
                                              color: _isValidExpression
                                                  ? Colors.teal.shade900
                                                  : textColor.withValues(alpha: 0.4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Función pública que despliega el Spotlight Calculator usando [showGeneralDialog].
Future<double?> showSpotlightCalculator(BuildContext context) {
  return showGeneralDialog<double>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'SpotlightCalculator',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SpotlightCalculator();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Animación suave de escala y desvanecimiento
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
