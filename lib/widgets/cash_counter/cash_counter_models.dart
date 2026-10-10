import 'package:intl/intl.dart';

enum CashCurrency { cordoba, dollar }

class DenominationConfig {
  final double value;
  final bool isCoin;
  final CashCurrency currency;

  const DenominationConfig({
    required this.value,
    required this.isCoin,
    required this.currency,
  });

  String get label {
    final fmt = NumberFormat('#,##0.##', 'en_US');
    if (currency == CashCurrency.cordoba) {
      return 'C\$ ${fmt.format(value)}';
    } else {
      return '\$ ${fmt.format(value)}';
    }
  }

  String get typeLabel => isCoin ? 'Moneda' : 'Billete';
}

class CashDenominations {
  static const List<DenominationConfig> cordobas = [
    DenominationConfig(value: 1000.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 500.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 200.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 100.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 50.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 20.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 10.0, isCoin: false, currency: CashCurrency.cordoba),
    DenominationConfig(value: 5.0, isCoin: true, currency: CashCurrency.cordoba),
    DenominationConfig(value: 1.0, isCoin: true, currency: CashCurrency.cordoba),
    DenominationConfig(value: 0.50, isCoin: true, currency: CashCurrency.cordoba),
  ];

  static const List<DenominationConfig> dollars = [
    DenominationConfig(value: 100.0, isCoin: false, currency: CashCurrency.dollar),
    DenominationConfig(value: 50.0, isCoin: false, currency: CashCurrency.dollar),
    DenominationConfig(value: 20.0, isCoin: false, currency: CashCurrency.dollar),
    DenominationConfig(value: 10.0, isCoin: false, currency: CashCurrency.dollar),
    DenominationConfig(value: 5.0, isCoin: false, currency: CashCurrency.dollar),
    DenominationConfig(value: 1.0, isCoin: false, currency: CashCurrency.dollar),
  ];
}

class CashCountRecord {
  final String branchId;
  final String userId;
  final DateTime date;
  final double exchangeRate;
  final Map<double, int> cordobaCounts;
  final Map<double, int> dollarCounts;
  final DateTime updatedAt;

  CashCountRecord({
    required this.branchId,
    required this.userId,
    required this.date,
    this.exchangeRate = 36.62,
    Map<double, int>? cordobaCounts,
    Map<double, int>? dollarCounts,
    DateTime? updatedAt,
  })  : cordobaCounts = cordobaCounts ?? {},
        dollarCounts = dollarCounts ?? {},
        updatedAt = updatedAt ?? DateTime.now();

  double get totalCordobas {
    double sum = 0.0;
    for (final entry in cordobaCounts.entries) {
      sum += entry.key * entry.value;
    }
    return sum;
  }

  double get totalDollars {
    double sum = 0.0;
    for (final entry in dollarCounts.entries) {
      sum += entry.key * entry.value;
    }
    return sum;
  }

  double get totalDollarsInCordobas => totalDollars * exchangeRate;

  double get grandTotalCordobas => totalCordobas + totalDollarsInCordobas;

  int get totalCordobaPieces {
    int sum = 0;
    for (final count in cordobaCounts.values) {
      sum += count;
    }
    return sum;
  }

  int get totalDollarPieces {
    int sum = 0;
    for (final count in dollarCounts.values) {
      sum += count;
    }
    return sum;
  }

  int getCordobaCount(double value) => cordobaCounts[value] ?? 0;
  int getDollarCount(double value) => dollarCounts[value] ?? 0;

  CashCountRecord copyWith({
    String? branchId,
    String? userId,
    DateTime? date,
    double? exchangeRate,
    Map<double, int>? cordobaCounts,
    Map<double, int>? dollarCounts,
    DateTime? updatedAt,
  }) {
    return CashCountRecord(
      branchId: branchId ?? this.branchId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      cordobaCounts: cordobaCounts ?? Map.from(this.cordobaCounts),
      dollarCounts: dollarCounts ?? Map.from(this.dollarCounts),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final cordobaMap = <String, int>{};
    for (final e in cordobaCounts.entries) {
      cordobaMap[e.key.toString()] = e.value;
    }

    final dollarMap = <String, int>{};
    for (final e in dollarCounts.entries) {
      dollarMap[e.key.toString()] = e.value;
    }

    return {
      'branchId': branchId,
      'userId': userId,
      'date': date.toIso8601String(),
      'exchangeRate': exchangeRate,
      'cordobaCounts': cordobaMap,
      'dollarCounts': dollarMap,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CashCountRecord.fromJson(Map<String, dynamic> json) {
    final cordobaCounts = <double, int>{};
    if (json['cordobaCounts'] is Map) {
      (json['cordobaCounts'] as Map).forEach((k, v) {
        final val = double.tryParse(k.toString());
        final qty = int.tryParse(v.toString()) ?? 0;
        if (val != null) cordobaCounts[val] = qty;
      });
    }

    final dollarCounts = <double, int>{};
    if (json['dollarCounts'] is Map) {
      (json['dollarCounts'] as Map).forEach((k, v) {
        final val = double.tryParse(k.toString());
        final qty = int.tryParse(v.toString()) ?? 0;
        if (val != null) dollarCounts[val] = qty;
      });
    }

    return CashCountRecord(
      branchId: json['branchId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 36.62,
      cordobaCounts: cordobaCounts,
      dollarCounts: dollarCounts,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  String generateTextSummary({String? userName, double? expectedCash}) {
    final f = NumberFormat('#,##0.00', 'en_US');
    final dateFmt = DateFormat('dd/MM/yyyy');
    final buffer = StringBuffer();

    buffer.writeln('📋 DESGLOSE DE ARQUEO DE CAJA');
    buffer.writeln('Fecha: ${dateFmt.format(date)}');
    if (userName != null && userName.isNotEmpty) {
      buffer.writeln('Usuario: $userName');
    }
    buffer.writeln('----------------------------------------');

    buffer.writeln('🇳🇮 CÓRDOBAS (C\$):');
    for (final den in CashDenominations.cordobas) {
      final count = getCordobaCount(den.value);
      if (count > 0) {
        final subtotal = den.value * count;
        buffer.writeln('  ${den.label.padRight(10)} x ${count.toString().padLeft(4)} = C\$ ${f.format(subtotal).padLeft(10)}');
      }
    }
    buffer.writeln('Subtotal C\$: C\$ ${f.format(totalCordobas)} ($totalCordobaPieces piezas)');
    buffer.writeln('----------------------------------------');

    buffer.writeln('🇺🇸 DÓLARES (\$):');
    for (final den in CashDenominations.dollars) {
      final count = getDollarCount(den.value);
      if (count > 0) {
        final subtotal = den.value * count;
        buffer.writeln('  ${den.label.padRight(10)} x ${count.toString().padLeft(4)} = \$ ${f.format(subtotal).padLeft(10)}');
      }
    }
    buffer.writeln('Subtotal USD: \$ ${f.format(totalDollars)} ($totalDollarPieces piezas)');
    buffer.writeln('Tasa de Cambio: 1 USD = C\$ ${f.format(exchangeRate)}');
    buffer.writeln('Equivalente USD en C\$: C\$ ${f.format(totalDollarsInCordobas)}');
    buffer.writeln('========================================');
    buffer.writeln('GRAN TOTAL FÍSICO: C\$ ${f.format(grandTotalCordobas)}');

    if (expectedCash != null) {
      final diff = grandTotalCordobas - expectedCash;
      buffer.writeln('Efectivo en Sistema: C\$ ${f.format(expectedCash)}');
      if (diff.abs() < 0.01) {
        buffer.writeln('Estado: CUADRADO EXACTO (C\$ 0.00)');
      } else if (diff > 0) {
        buffer.writeln('Estado: SOBRANTE de C\$ ${f.format(diff)}');
      } else {
        buffer.writeln('Estado: FALTANTE de C\$ ${f.format(diff.abs())}');
      }
    }
    buffer.writeln('========================================');

    return buffer.toString();
  }
}
