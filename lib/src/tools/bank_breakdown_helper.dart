/// Etiqueta usada cuando un pago por tarjeta o transferencia no incluye banco.
const String kUnspecifiedBankLabel = 'Sin especificar';

const List<String> _knownBanks = [
  'BAC',
  'LAFISE',
  'BANPRO',
  'FICOHSA',
  'BDF',
];

/// Entrada agregada de pagos agrupados por banco.
class BankBreakdownEntry {
  final String bankName;
  final int count;
  final int totalCents;

  const BankBreakdownEntry({
    required this.bankName,
    required this.count,
    required this.totalCents,
  });
}

/// Extrae el nombre del banco desde [bankReference] (ej. `"BAC - 123456"` → `"BAC"`).
///
/// Para registros históricos sin banco (vacío o solo numérico como `"123456"`),
/// retorna [kUnspecifiedBankLabel].
String extractBankFromReference(String? bankReference) {
  final raw = bankReference?.trim() ?? '';
  if (raw.isEmpty) return kUnspecifiedBankLabel;

  final separatorIndex = raw.indexOf(' - ');
  if (separatorIndex > 0) {
    final prefix = raw.substring(0, separatorIndex).trim();
    if (prefix.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(prefix)) {
      return prefix.toUpperCase();
    }
  }

  final upper = raw.toUpperCase();
  if (_knownBanks.contains(upper)) {
    return upper;
  }

  return kUnspecifiedBankLabel;
}

/// Agrupa una colección de documentos por banco usando [bankReferenceOf] y [amountOf].
List<BankBreakdownEntry> groupPaymentsByBank<T>(
  Iterable<T> items, {
  required String? Function(T item) bankReferenceOf,
  required int Function(T item) amountOf,
}) {
  final counts = <String, int>{};
  final totals = <String, int>{};

  for (final item in items) {
    final bank = extractBankFromReference(bankReferenceOf(item));
    counts[bank] = (counts[bank] ?? 0) + 1;
    totals[bank] = (totals[bank] ?? 0) + amountOf(item);
  }

  final entries = counts.keys
      .map(
        (bank) => BankBreakdownEntry(
          bankName: bank,
          count: counts[bank]!,
          totalCents: totals[bank]!,
        ),
      )
      .toList();

  entries.sort((a, b) {
    if (a.bankName == kUnspecifiedBankLabel && b.bankName != kUnspecifiedBankLabel) {
      return 1;
    }
    if (b.bankName == kUnspecifiedBankLabel && a.bankName != kUnspecifiedBankLabel) {
      return -1;
    }
    final byAmount = b.totalCents.compareTo(a.totalCents);
    if (byAmount != 0) return byAmount;
    return a.bankName.compareTo(b.bankName);
  });

  return entries;
}

/// Helper conveniente para agrupar facturas y recibos de `TotalsResult` por banco.
class _BankDocAmount {
  final String? bankReference;
  final int amount;

  const _BankDocAmount(this.bankReference, this.amount);
}

List<BankBreakdownEntry> groupReferencesByBank(
  Iterable<({String? bankReference, int amount})> docs,
) {
  return groupPaymentsByBank(
    docs.map((d) => _BankDocAmount(d.bankReference, d.amount)),
    bankReferenceOf: (d) => d.bankReference,
    amountOf: (d) => d.amount,
  );
}
