import 'package:kardex_business/src/domain/models/common/client_info.dart';
import 'package:kardex_business/src/domain/models/common/payment_detail.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';

enum PaymentMethod {
  cash,
  transfer,
  card,
  check,
  other
  ;

  String get display {
    switch (this) {
      case PaymentMethod.cash:
        return "Efectivo";
      case PaymentMethod.transfer:
        return "Transferencia";
      case PaymentMethod.card:
        return "Tarjeta";
      case PaymentMethod.check:
        return "Cheque";
      case PaymentMethod.other:
        return "Otro";
    }
  }
}

class AppliedInvoice {
  final String invoiceId;
  final String docNumber;
  final int amountApplied;

  AppliedInvoice({
    required this.invoiceId,
    required this.docNumber,
    required this.amountApplied,
  });

  factory AppliedInvoice.fromJson(Map<String, dynamic> json) => AppliedInvoice(
    invoiceId: json['invoiceId'],
    docNumber: json['docNumber'],
    amountApplied: json['amountApplied'],
  );

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'docNumber': docNumber,
    'amountApplied': amountApplied,
  };
}

class AppliedDevolution {
  final String devolutionId;
  final String docNumber;
  final int amountApplied;

  AppliedDevolution({
    required this.devolutionId,
    required this.docNumber,
    required this.amountApplied,
  });

  factory AppliedDevolution.fromJson(Map<String, dynamic> json) => AppliedDevolution(
    devolutionId: json['devolutionId'],
    docNumber: json['docNumber'],
    amountApplied: json['amountApplied'],
  );

  Map<String, dynamic> toJson() => {
    'devolutionId': devolutionId,
    'docNumber': docNumber,
    'amountApplied': amountApplied,
  };
}

class AppliedCreditNote {
  final String creditNoteId;
  final String docNumber;
  final int amountApplied;

  AppliedCreditNote({
    required this.creditNoteId,
    required this.docNumber,
    required this.amountApplied,
  });

  factory AppliedCreditNote.fromJson(Map<String, dynamic> json) => AppliedCreditNote(
    creditNoteId: json['creditNoteId'],
    docNumber: json['docNumber'] ?? "",
    amountApplied: json['amountApplied'],
  );

  Map<String, dynamic> toJson() => {
    'creditNoteId': creditNoteId,
    'docNumber': docNumber,
    'amountApplied': amountApplied,
  };
}

class BaseReceipt {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final List<AppliedInvoice> appliedInvoices;
  final List<AppliedDevolution> appliedDevolutions;
  final List<AppliedCreditNote> appliedCreditNotes;
  final PaymentMethod paymentMethod;
  final String bankReference;
  final PaymentDetail? paymentDetail;
  final int total;
  final UserInfo createdBy;
  final String? shiftId;

  BaseReceipt({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    this.docNumber = "",
    required this.appliedInvoices,
    required this.appliedDevolutions,
    this.appliedCreditNotes = const [],
    required this.paymentMethod,
    this.bankReference = "",
    this.paymentDetail,
    required this.total,
    required this.createdBy,
    this.shiftId,
  });

  factory BaseReceipt.fromJson(Map<String, dynamic> json) => BaseReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    appliedDevolutions: (json['appliedDevolutions'] as List).map((e) => AppliedDevolution.fromJson(e)).toList(),
    appliedCreditNotes: json['appliedCreditNotes'] != null
        ? (json['appliedCreditNotes'] as List).map((e) => AppliedCreditNote.fromJson(e)).toList()
        : const [],
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
    shiftId: json['shiftId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
    'docNumber': docNumber,
    'appliedInvoices': appliedInvoices.map((e) => e.toJson()).toList(),
    'appliedDevolutions': appliedDevolutions.map((e) => e.toJson()).toList(),
    'appliedCreditNotes': appliedCreditNotes.map((e) => e.toJson()).toList(),
    'paymentMethod': paymentMethod.name,
    'bankReference': bankReference,
    if (paymentDetail != null) 'paymentDetail': paymentDetail!.toJson(),
    'total': total,
    'createdBy': createdBy.toJson(),
    if (shiftId != null) 'shiftId': shiftId,
  };
}

class CreateReceipt extends BaseReceipt {
  CreateReceipt({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    super.docNumber,
    required super.appliedInvoices,
    required super.appliedDevolutions,
    super.appliedCreditNotes = const [],
    required super.paymentMethod,
    super.bankReference,
    super.paymentDetail,
    required super.total,
    required super.createdBy,
    super.shiftId,
  });

  factory CreateReceipt.fromJson(Map<String, dynamic> json) => CreateReceipt(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    appliedDevolutions: (json['appliedDevolutions'] as List).map((e) => AppliedDevolution.fromJson(e)).toList(),
    appliedCreditNotes: json['appliedCreditNotes'] != null
        ? (json['appliedCreditNotes'] as List).map((e) => AppliedCreditNote.fromJson(e)).toList()
        : const [],
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
    shiftId: json['shiftId'] as String?,
  );
}

class UpdateReceipt {
  UpdateReceipt();
}

class ReceiptInDb extends BaseReceipt {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? cancelledAt;
  final UserInfo? cancelledBy;
  final String? cancellationReason;
  final String? cancellationRequestId;

  ReceiptInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    super.docNumber,
    required super.appliedInvoices,
    required super.appliedDevolutions,
    super.appliedCreditNotes = const [],
    required super.paymentMethod,
    super.bankReference,
    super.paymentDetail,
    required super.total,
    required this.createdAt,
    required this.updatedAt,
    required super.createdBy,
    super.shiftId,
    this.isDeleted = false,
    this.deletedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationRequestId,
  });

  bool get isCancelled => isDeleted || cancelledAt != null;

  factory ReceiptInDb.fromJson(Map<String, dynamic> json) => ReceiptInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    appliedInvoices: (json['appliedInvoices'] as List).map((e) => AppliedInvoice.fromJson(e)).toList(),
    appliedDevolutions: (json['appliedDevolutions'] as List).map((e) => AppliedDevolution.fromJson(e)).toList(),
    appliedCreditNotes: json['appliedCreditNotes'] != null
        ? (json['appliedCreditNotes'] as List).map((e) => AppliedCreditNote.fromJson(e)).toList()
        : const [],
    paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    total: json['total'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: (json['updatedAt'] != null) ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
    createdBy: UserInfo.fromJson(json['createdBy']),
    shiftId: json['shiftId'] as String?,
    isDeleted: json['isDeleted'] as bool? ?? false,
    deletedAt: json['deletedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['deletedAt'] as num).toInt())
        : null,
    cancelledAt: json['cancelledAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['cancelledAt'] as num).toInt())
        : null,
    cancelledBy: json['cancelledBy'] != null
        ? UserInfo.fromJson(json['cancelledBy'] as Map<String, dynamic>)
        : null,
    cancellationReason: json['cancellationReason'] as String?,
    cancellationRequestId: json['cancellationRequestId'] as String?,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': deletedAt!.millisecondsSinceEpoch,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.millisecondsSinceEpoch,
      if (cancelledBy != null) 'cancelledBy': cancelledBy!.toJson(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancellationRequestId != null) 'cancellationRequestId': cancellationRequestId,
    });
    return data;
  }
}
