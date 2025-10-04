import 'package:kardex_app_front/src/domain/models/common/client_info.dart';

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
  final ClientInfo clientInfo;
  final String docNumber;
  final List<AppliedInvoice> appliedInvoices;
  final PaymentMethod paymentMethod;
  final String bankReference;
  final int total;

  BaseReceipt({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    this.docNumber = "",
    required this.appliedInvoices,
    required this.paymentMethod,
    this.bankReference = "",
    required this.total,
  });

  factory BaseReceipt.fromJson(Map<String, dynamic> json) => BaseReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
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
    required super.clientInfo,
    super.docNumber,
    required super.appliedInvoices,
    required super.paymentMethod,
    super.bankReference,
    required super.total,
  });

  factory CreateReceipt.fromJson(Map<String, dynamic> json) => CreateReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
  );
}

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
    required super.clientInfo,
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
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    total: json['total'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: (json['updatedAt'] != null) ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
