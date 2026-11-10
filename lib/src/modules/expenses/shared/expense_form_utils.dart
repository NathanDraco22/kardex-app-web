/// Utilidades de parseo, formato y resolución de estado para los formularios de
/// gastos.
library;

import 'package:kardex_business/kardex_business.dart';

/// Convierte un texto de monto a centavos.
///
/// Política de aceptación:
/// - Se permiten únicamente dígitos, comas y puntos; cualquier otro carácter
///   (signos, paréntesis, letras) invalida el monto.
/// - Si aparecen ambos separadores, el último es el decimal y el otro agrupa
///   miles: `1,234.56`, `1.234,56`, `1,234,567.89`, `1.234.567,89`.
/// - Con un solo separador y dos o menos dígitos a la derecha se interpreta
///   como decimal: `12,50`, `12.50`, `1,5`.
/// - Con un solo separador y exactamente tres dígitos a la derecha se
///   interpreta como separador de miles: `1,234`, `1.234`, `12.345`.
/// - Los grupos de miles deben tener 1–3 dígitos en el primero y exactamente 3
///   en los siguientes. La parte decimal admite como máximo 2 dígitos.
/// - Se rechazan los formatos ambiguos o malformados como `1.234.56`,
///   `1,234,56`, `1.234,567`, `1,234,567`, `1.2345` y `1,2345`.
/// - Se rechazan los valores no positivos.
int? parseExpenseAmountCents(String raw) {
  final input = raw.trim();
  if (input.isEmpty) return null;
  if (RegExp(r'[^0-9.,]').hasMatch(input)) return null;

  final hasComma = input.contains(',');
  final hasDot = input.contains('.');

  if (hasComma && hasDot) {
    return _parseWithDecimalSeparator(input);
  }

  if (hasComma || hasDot) {
    return _parseWithSingleSeparator(input, hasComma ? ',' : '.');
  }

  if (!_isDigits(input)) return null;
  return _centsFromNormalized(input);
}

int? _parseWithDecimalSeparator(String input) {
  final decimalSeparator = input.lastIndexOf(',') > input.lastIndexOf('.') ? ',' : '.';
  final groupingSeparator = decimalSeparator == ',' ? '.' : ',';
  final decimalIndex = input.lastIndexOf(decimalSeparator);

  final integerPart = input.substring(0, decimalIndex);
  final decimalPart = input.substring(decimalIndex + 1);

  if (integerPart.isEmpty || decimalPart.isEmpty) return null;
  if (integerPart.contains(decimalSeparator)) return null;
  if (!_isValidDecimalPart(decimalPart)) return null;
  if (!_isValidGroupedInteger(integerPart, groupingSeparator)) return null;

  final normalizedInteger = integerPart.replaceAll(groupingSeparator, '');
  return _centsFromNormalized('$normalizedInteger.$decimalPart');
}

int? _parseWithSingleSeparator(String input, String separator) {
  final parts = input.split(separator);
  if (parts.length != 2) return null;

  final integerPart = parts[0];
  final rightPart = parts[1];
  if (!_isDigits(integerPart) || !_isDigits(rightPart)) return null;

  if (rightPart.length <= 2) {
    return _centsFromNormalized('$integerPart.$rightPart');
  }

  if (rightPart.length == 3 && _isValidFirstGroup(integerPart)) {
    return _centsFromNormalized('$integerPart$rightPart');
  }

  return null;
}

bool _isValidGroupedInteger(String integerPart, String separator) {
  if (integerPart.isEmpty) return false;

  final groups = integerPart.split(separator);
  if (groups.length == 1) return _isDigits(integerPart);
  if (groups.any((group) => group.isEmpty || !_isDigits(group))) return false;
  if (!_isValidFirstGroup(groups.first)) return false;

  return groups.skip(1).every((group) => group.length == 3);
}

bool _isValidFirstGroup(String group) {
  return group.isNotEmpty && group.length <= 3 && _isDigits(group);
}

bool _isValidDecimalPart(String decimalPart) {
  return decimalPart.isNotEmpty && decimalPart.length <= 2 && _isDigits(decimalPart);
}

bool _isDigits(String value) => RegExp(r'^\d+$').hasMatch(value);

int? _centsFromNormalized(String normalized) {
  final parts = normalized.split('.');
  if (parts.length > 2) return null;

  final whole = int.tryParse(parts[0]);
  if (whole == null) return null;

  var fraction = 0;
  if (parts.length == 2) {
    final decimalPart = parts[1];
    if (decimalPart.isEmpty || decimalPart.length > 2 || !_isDigits(decimalPart)) {
      return null;
    }
    fraction = int.parse(decimalPart.padRight(2, '0'));
  }

  final cents = whole * 100 + fraction;
  return cents > 0 ? cents : null;
}

/// Formatea centavos para precargar el campo de monto.
///
/// Devuelve una cadena vacía para valores no positivos; en caso contrario usa
/// el formato `1,234.56` que [parseExpenseAmountCents] entiende.
String formatExpenseAmountInput(int cents) {
  if (cents <= 0) return '';

  final whole = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  final wholeText = whole.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < wholeText.length; index++) {
    if (index > 0 && (wholeText.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(wholeText[index]);
  }

  return '${buffer.toString()}.$fraction';
}

/// Resuelve el estado que debe guardar el formulario.
///
/// Si el usuario no tocó el interruptor de crédito y existe un estado
/// original, se conserva tal cual para no degradar `cancelled`,
/// `partiallyPaid` o `draft` a `open`.
ExpenseStatus resolveExpenseStatus({
  ExpenseStatus? original,
  required bool isCredit,
  required bool creditChanged,
}) {
  if (original != null && !creditChanged) return original;
  return isCredit ? ExpenseStatus.open : ExpenseStatus.paid;
}

/// Resuelve la fecha de vencimiento que debe guardar el formulario.
///
/// Al desactivar el crédito se limpia la fecha solo si el usuario cambió el
/// interruptor; de lo contrario se conserva el valor original. Con crédito
/// activo siempre se usa la fecha actual del formulario.
int? resolveExpirationDate({
  int? original,
  int? current,
  required bool isCredit,
  required bool creditChanged,
}) {
  if (!isCredit) return creditChanged ? null : original;
  return current;
}

/// Construye el mapa que consumen `CreateExpense.fromJson` y
/// `UpdateExpense.fromJson`.
///
/// Centraliza también la generación de `dateId` con el formato `YYYY-MM-DD`
/// que usan los registros existentes.
Map<String, dynamic> buildExpensePayload({
  required ExpenseType type,
  required String branchId,
  required UserInfo createdBy,
  required String docNumber,
  required String category,
  String? description,
  required int amount,
  required int date,
  required ExpenseStatus status,
  int? expirationDate,
  String supplierId = '',
  String supplierName = '',
}) {
  return {
    'type': type.name,
    'branchId': branchId,
    'createdBy': createdBy.toJson(),
    'docNumber': docNumber,
    'category': category,
    'description': description,
    'amount': amount,
    'date': date,
    'dateId': DateTimeTool.formatyyyyMMdd(DateTime.fromMillisecondsSinceEpoch(date)),
    'status': status.name,
    'expirationDate': expirationDate,
    'supplierId': supplierId,
    'supplierName': supplierName,
  };
}
