import 'dart:convert';
import 'dart:typed_data';

/// Convierte las columnas `date` y `expirationDate` de un CSV de Cuentas por
/// Pagar a Unix timestamp en milisegundos usando la zona horaria local del
/// dispositivo del usuario.
///
/// - Si la fecha ya es un entero Unix timestamp o viene vacía, la preserva.
/// - Si el formato es inválido (ej. `31/02/2026` o texto no reconocido), la
///   deja intacta para que el backend reporte el error en el número de fila
///   exacto durante la vista previa.
Uint8List normalizeAccountsPayableCsvDates(Uint8List bytes) {
  if (bytes.isEmpty) return bytes;

  String text;
  try {
    text = utf8.decode(bytes);
  } catch (_) {
    return bytes;
  }

  final hasBom = text.startsWith('\uFEFF');
  final body = hasBom ? text.substring(1) : text;
  final lines = const LineSplitter().convert(body);
  if (lines.isEmpty) return bytes;

  final headerIndex = lines.indexWhere((line) => line.trim().isNotEmpty);
  if (headerIndex == -1) return bytes;

  final headerLine = lines[headerIndex];
  final delimiter = _countChar(headerLine, ';') > _countChar(headerLine, ',') ? ';' : ',';

  final headers = _parseCsvRow(headerLine, delimiter).map((h) => h.trim()).toList();
  final dateIdx = headers.indexOf('date');
  final expIdx = headers.indexOf('expirationDate');
  if (dateIdx == -1 && expIdx == -1) return bytes;

  var changed = false;
  final outLines = <String>[...lines];

  for (var i = headerIndex + 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;

    final fields = _parseCsvRow(line, delimiter);
    var rowChanged = false;

    for (final idx in [dateIdx, expIdx]) {
      if (idx < 0 || idx >= fields.length) continue;
      final converted = _tryParseLocalDateToUnixMs(fields[idx]);
      if (converted != null && converted != fields[idx].trim()) {
        fields[idx] = converted;
        rowChanged = true;
      }
    }

    if (rowChanged) {
      outLines[i] = _encodeCsvRow(fields, delimiter);
      changed = true;
    }
  }

  if (!changed) return bytes;

  final rebuilt = '${hasBom ? '\uFEFF' : ''}${outLines.join('\n')}${body.endsWith('\n') ? '\n' : ''}';
  return Uint8List.fromList(utf8.encode(rebuilt));
}

int _countChar(String input, String char) {
  var count = 0;
  for (var i = 0; i < input.length; i++) {
    if (input[i] == char) count++;
  }
  return count;
}

String? _tryParseLocalDateToUnixMs(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  if (RegExp(r'^-?\d+$').hasMatch(text)) return null;

  int? year;
  int? month;
  int? day;

  final ymd = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$').firstMatch(text);
  if (ymd != null) {
    year = int.parse(ymd.group(1)!);
    month = int.parse(ymd.group(2)!);
    day = int.parse(ymd.group(3)!);
  } else {
    final dmy = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(text);
    if (dmy != null) {
      day = int.parse(dmy.group(1)!);
      month = int.parse(dmy.group(2)!);
      year = int.parse(dmy.group(3)!);
    }
  }

  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  final dt = DateTime(year, month, day);
  if (dt.year != year || dt.month != month || dt.day != day) return null;

  return dt.millisecondsSinceEpoch.toString();
}

List<String> _parseCsvRow(String line, String delimiter) {
  final fields = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch == delimiter && !inQuotes) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(ch);
    }
  }
  fields.add(buffer.toString());
  return fields;
}

String _encodeCsvRow(List<String> fields, String delimiter) {
  return fields.map((field) {
    if (field.contains(delimiter) || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }).join(delimiter);
}
