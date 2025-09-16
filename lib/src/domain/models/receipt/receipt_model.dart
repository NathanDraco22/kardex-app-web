enum PaymentMethod {
  cash,
  transfer,
  card,
  check,
  other,
}

// --- Modelos Anidados ---
class AppliedInvoice {
  final String invoiceId;
  final int amountApplied;

  AppliedInvoice({
    required this.invoiceId,
    required this.amountApplied,
  });

  factory AppliedInvoice.fromJson(Map<String, dynamic> json) => AppliedInvoice(
    invoiceId: json['invoiceId'],
    amountApplied: json['amountApplied'],
  );

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'amountApplied': amountApplied,
  };
}

// --- Modelos Principales de Recibo ---
class BaseReceipt {
  final String branchId;
  final String clientId;
  final String docNumber;
  final List<AppliedInvoice> appliedInvoices;
  final PaymentMethod paymentMethod;
  final String bankReference;
  final int total;

  BaseReceipt({
    required this.branchId,
    required this.clientId,
    this.docNumber = "",
    required this.appliedInvoices,
    required this.paymentMethod,
    this.bankReference = "",
    required this.total,
  });

  factory BaseReceipt.fromJson(Map<String, dynamic> json) => BaseReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'docNumber': docNumber,
    'appliedInvoices': appliedInvoices.map((e) => e.toJson()).toList(),
    'paymentMethod': paymentMethod.name,
    'bankReference': bankReference,
    'total': total,
  };
}

class CreateReceipt extends BaseReceipt {
  CreateReceipt({
    required super.branchId,
    required super.clientId,
    super.docNumber,
    required super.appliedInvoices,
    required super.paymentMethod,
    super.bankReference,
    required super.total,
  });

  factory CreateReceipt.fromJson(Map<String, dynamic> json) => CreateReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
  );
}

// Este modelo está vacío, tal como en el original.
class UpdateReceipt {
  UpdateReceipt();
}

class ReceiptInDb extends BaseReceipt {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReceiptInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    super.docNumber,
    required super.appliedInvoices,
    required super.paymentMethod,
    super.bankReference,
    required super.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReceiptInDb.fromJson(Map<String, dynamic> json) => ReceiptInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: (json['updatedAt'] != null) ? DateTime.parse(json['updatedAt']) : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
