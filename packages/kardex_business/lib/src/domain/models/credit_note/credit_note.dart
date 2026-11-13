import '../common/client_info.dart';
import '../common/sale_item_model.dart';
import '../common/user_info.dart';

enum CreditNoteType {
  devolution,
  amount;

  static CreditNoteType get monto => amount;

  String get display {
    switch (this) {
      case CreditNoteType.devolution:
        return "Por Devolución";
      case CreditNoteType.amount:
        return "Por Monto";
    }
  }
}

enum CreditNoteStatus {
  emitted,
  approved,
  rejected,
  open,
  confirmed,
  cancelled,
  applied;

  String get display {
    switch (this) {
      case CreditNoteStatus.emitted:
        return "Emitida";
      case CreditNoteStatus.approved:
        return "Aprobada";
      case CreditNoteStatus.rejected:
        return "Rechazada";
      case CreditNoteStatus.open:
        return "Abierta";
      case CreditNoteStatus.confirmed:
        return "Confirmada";
      case CreditNoteStatus.cancelled:
        return "Cancelada";
      case CreditNoteStatus.applied:
        return "Aplicada";
    }
  }
}

class BaseCreditNote {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final CreditNoteType type;
  final String docNumber;
  final String originalInvoiceId;
  final String originalInvoiceDocNumber;
  final List<SaleItem> returnedItems;
  final int amount;
  final String description;
  final CreditNoteStatus status;
  final UserInfo createdBy;
  final UserInfo? approvedBy;
  final DateTime? approvedAt;
  final UserInfo? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? appliedReceiptId;
  final String? appliedReceiptDocNumber;
  final DateTime? appliedAt;
  final String? idempotencyKey;

  int get total => amount;
  String get invoiceId => originalInvoiceId;
  String get invoiceDocNumber => originalInvoiceDocNumber;

  BaseCreditNote({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    required this.type,
    this.docNumber = "",
    this.originalInvoiceId = "",
    this.originalInvoiceDocNumber = "",
    this.returnedItems = const [],
    required this.amount,
    this.description = "",
    this.status = CreditNoteStatus.emitted,
    required this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.appliedReceiptId,
    this.appliedReceiptDocNumber,
    this.appliedAt,
    this.idempotencyKey,
  });

  factory BaseCreditNote.fromJson(Map<String, dynamic> json) => BaseCreditNote(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    type: CreditNoteType.values.byName(json['type']),
    docNumber: json['docNumber'] ?? "",
    originalInvoiceId: json['originalInvoiceId'] ?? "",
    originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
    returnedItems: json['returnedItems'] != null
        ? (json['returnedItems'] as List)
              .map((e) => SaleItem.fromJson(e))
              .toList()
        : const [],
    amount: json['amount'],
    description: json['description'] ?? "",
    status: CreditNoteStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CreditNoteStatus.emitted,
    ),
    createdBy: UserInfo.fromJson(json['createdBy']),
    approvedBy: json['approvedBy'] != null
        ? UserInfo.fromJson(json['approvedBy'])
        : null,
    approvedAt: json['approvedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['approvedAt'])
        : null,
    rejectedBy: json['rejectedBy'] != null
        ? UserInfo.fromJson(json['rejectedBy'])
        : null,
    rejectedAt: json['rejectedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['rejectedAt'])
        : null,
    rejectionReason: json['rejectionReason'],
    appliedReceiptId: json['appliedReceiptId'],
    appliedReceiptDocNumber: json['appliedReceiptDocNumber'],
    appliedAt: json['appliedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['appliedAt'])
        : null,
    idempotencyKey: json['idempotencyKey'],
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'branchId': branchId,
      'clientId': clientId,
      'clientInfo': clientInfo.toJson(),
      'type': type.name,
      'docNumber': docNumber,
      'originalInvoiceId': originalInvoiceId,
      'originalInvoiceDocNumber': originalInvoiceDocNumber,
      'returnedItems': returnedItems.map((e) => e.toJson()).toList(),
      'amount': amount,
      'description': description,
      'status': status.name,
      'createdBy': createdBy.toJson(),
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'rejectedBy': rejectedBy?.toJson(),
      'rejectedAt': rejectedAt?.millisecondsSinceEpoch,
      'rejectionReason': rejectionReason,
      'appliedReceiptId': appliedReceiptId,
      'appliedReceiptDocNumber': appliedReceiptDocNumber,
      'appliedAt': appliedAt?.millisecondsSinceEpoch,
    };
    if (idempotencyKey != null) {
      data['idempotencyKey'] = idempotencyKey;
    }
    return data;
  }
}

class CreateCreditNote extends BaseCreditNote {
  CreateCreditNote({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    required super.type,
    super.docNumber,
    super.originalInvoiceId,
    super.originalInvoiceDocNumber,
    super.returnedItems = const [],
    required super.amount,
    super.description = "",
    super.status = CreditNoteStatus.emitted,
    required super.createdBy,
    super.approvedBy,
    super.approvedAt,
    super.rejectedBy,
    super.rejectedAt,
    super.rejectionReason,
    super.idempotencyKey,
  });

  factory CreateCreditNote.fromJson(Map<String, dynamic> json) =>
      CreateCreditNote(
        branchId: json['branchId'],
        clientId: json['clientId'],
        clientInfo: ClientInfo.fromJson(json['clientInfo']),
        type: CreditNoteType.values.byName(json['type']),
        docNumber: json['docNumber'] ?? "",
        originalInvoiceId: json['originalInvoiceId'] ?? "",
        originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
        returnedItems: json['returnedItems'] != null
            ? (json['returnedItems'] as List)
                  .map((e) => SaleItem.fromJson(e))
                  .toList()
            : const [],
        amount: json['amount'],
        description: json['description'] ?? "",
        status: CreditNoteStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => CreditNoteStatus.emitted,
        ),
        createdBy: UserInfo.fromJson(json['createdBy']),
        approvedBy: json['approvedBy'] != null
            ? UserInfo.fromJson(json['approvedBy'])
            : null,
        approvedAt: json['approvedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['approvedAt'])
            : null,
        rejectedBy: json['rejectedBy'] != null
            ? UserInfo.fromJson(json['rejectedBy'])
            : null,
        rejectedAt: json['rejectedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['rejectedAt'])
            : null,
        rejectionReason: json['rejectionReason'],
        idempotencyKey: json['idempotencyKey'],
      );
}

class UpdateCreditNote {
  final CreditNoteStatus? status;
  final UserInfo? approvedBy;
  final DateTime? approvedAt;
  final UserInfo? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? appliedReceiptId;
  final String? appliedReceiptDocNumber;
  final DateTime? appliedAt;

  UpdateCreditNote({
    this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.appliedReceiptId,
    this.appliedReceiptDocNumber,
    this.appliedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'status': status?.name,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'rejectedBy': rejectedBy?.toJson(),
      'rejectedAt': rejectedAt?.millisecondsSinceEpoch,
      'rejectionReason': rejectionReason,
      'appliedReceiptId': appliedReceiptId,
      'appliedReceiptDocNumber': appliedReceiptDocNumber,
      'appliedAt': appliedAt?.millisecondsSinceEpoch,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class CreditNoteInDb extends BaseCreditNote {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CreditNoteInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    required super.type,
    super.docNumber,
    super.originalInvoiceId,
    super.originalInvoiceDocNumber,
    super.returnedItems = const [],
    required super.amount,
    super.description = "",
    super.status = CreditNoteStatus.emitted,
    required super.createdBy,
    super.approvedBy,
    super.approvedAt,
    super.rejectedBy,
    super.rejectedAt,
    super.rejectionReason,
    super.appliedReceiptId,
    super.appliedReceiptDocNumber,
    super.appliedAt,
    super.idempotencyKey,
    required this.createdAt,
    this.updatedAt,
  });

  factory CreditNoteInDb.fromJson(Map<String, dynamic> json) => CreditNoteInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    type: CreditNoteType.values.byName(json['type']),
    docNumber: json['docNumber'] ?? "",
    originalInvoiceId: json['originalInvoiceId'] ?? "",
    originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
    returnedItems: json['returnedItems'] != null
        ? (json['returnedItems'] as List)
              .map((e) => SaleItem.fromJson(e))
              .toList()
        : const [],
    amount: json['amount'],
    description: json['description'] ?? "",
    status: CreditNoteStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CreditNoteStatus.emitted,
    ),
    createdBy: UserInfo.fromJson(json['createdBy']),
    approvedBy: json['approvedBy'] != null
        ? UserInfo.fromJson(json['approvedBy'])
        : null,
    approvedAt: json['approvedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['approvedAt'])
        : null,
    rejectedBy: json['rejectedBy'] != null
        ? UserInfo.fromJson(json['rejectedBy'])
        : null,
    rejectedAt: json['rejectedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['rejectedAt'])
        : null,
    rejectionReason: json['rejectionReason'],
    appliedReceiptId: json['appliedReceiptId'],
    appliedReceiptDocNumber: json['appliedReceiptDocNumber'],
    appliedAt: json['appliedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['appliedAt'])
        : null,
    idempotencyKey: json['idempotencyKey'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
        : null,
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
