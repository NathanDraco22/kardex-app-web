class ImportPreviewError {
  const ImportPreviewError({
    required this.row,
    this.field,
    required this.message,
  });

  final int row;
  final String? field;
  final String message;

  factory ImportPreviewError.fromJson(Map<String, dynamic> json) {
    return ImportPreviewError(
      row: (json['row'] as num?)?.toInt() ?? 0,
      field: json['field'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        if (field != null) 'field': field,
        'message': message,
      };
}

class ImportPreviewResult {
  const ImportPreviewResult({
    required this.status,
    required this.isValid,
    required this.importType,
    required this.totalRows,
    this.totalQuantity = 0,
    this.totalCost = 0,
    this.totalPrice = 0,
    this.totalCreditLimit = 0,
    this.totalInitialBalance = 0,
    this.errors = const [],
  });

  final String status;
  final bool isValid;
  final String importType;
  final int totalRows;
  final int totalQuantity;
  final int totalCost; // en centavos
  final int totalPrice; // en centavos
  final int totalCreditLimit; // en centavos
  final int totalInitialBalance; // en centavos
  final List<ImportPreviewError> errors;

  factory ImportPreviewResult.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'] as List<dynamic>? ?? [];
    return ImportPreviewResult(
      status: json['status'] as String? ?? 'success',
      isValid: json['isValid'] as bool? ?? false,
      importType: json['importType'] as String? ?? '',
      totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      totalCreditLimit: (json['totalCreditLimit'] as num?)?.toInt() ?? 0,
      totalInitialBalance: (json['totalInitialBalance'] as num?)?.toInt() ?? 0,
      errors: rawErrors
          .whereType<Map<String, dynamic>>()
          .map(ImportPreviewError.fromJson)
          .toList(),
    );
  }
}
