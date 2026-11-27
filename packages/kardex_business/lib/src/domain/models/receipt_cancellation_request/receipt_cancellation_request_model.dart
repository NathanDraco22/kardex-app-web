import 'package:kardex_business/src/domain/models/common/client_info.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/receipt/receipt_model.dart';

enum ReceiptCancellationRequestStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get display => switch (this) {
    ReceiptCancellationRequestStatus.pending => 'Pendiente',
    ReceiptCancellationRequestStatus.approved => 'Aprobada',
    ReceiptCancellationRequestStatus.rejected => 'Rechazada',
    ReceiptCancellationRequestStatus.cancelled => 'Cancelada',
  };

  static ReceiptCancellationRequestStatus fromApi(String? value) {
    return ReceiptCancellationRequestStatus.values.firstWhere(
      (e) => e.name == value?.toLowerCase(),
      orElse: () => ReceiptCancellationRequestStatus.pending,
    );
  }
}

class CreateReceiptCancellationRequest {
  final String receiptId;
  final String reason;
  final UserInfo requestedBy;

  const CreateReceiptCancellationRequest({
    required this.receiptId,
    required this.reason,
    required this.requestedBy,
  });

  Map<String, dynamic> toJson() => {
    'receiptId': receiptId,
    'reason': reason,
    'requestedBy': requestedBy.toJson(),
  };
}

class ReceiptCancellationRequestInDb {
  final String id;
  final String docNumber;
  final String branchId;
  final String receiptId;
  final String receiptDocNumber;
  final int receiptTotal;
  final PaymentMethod receiptPaymentMethod;
  final String? receiptShiftId;
  final String clientId;
  final ClientInfo clientInfo;
  final String reason;
  final UserInfo requestedBy;
  final ReceiptCancellationRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserInfo? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  const ReceiptCancellationRequestInDb({
    required this.id,
    required this.docNumber,
    required this.branchId,
    required this.receiptId,
    required this.receiptDocNumber,
    required this.receiptTotal,
    required this.receiptPaymentMethod,
    this.receiptShiftId,
    required this.clientId,
    required this.clientInfo,
    required this.reason,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory ReceiptCancellationRequestInDb.fromJson(Map<String, dynamic> json) {
    return ReceiptCancellationRequestInDb(
      id: json['id'] as String,
      docNumber: json['docNumber'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      receiptId: json['receiptId'] as String? ?? '',
      receiptDocNumber: json['receiptDocNumber'] as String? ?? '',
      receiptTotal: (json['receiptTotal'] as num?)?.toInt() ?? 0,
      receiptPaymentMethod: PaymentMethod.values.byName(
        (json['receiptPaymentMethod'] ?? 'cash').toString().toLowerCase(),
      ),
      receiptShiftId: json['receiptShiftId'] as String?,
      clientId: json['clientId'] as String? ?? '',
      clientInfo: ClientInfo.fromJson(
        (json['clientInfo'] as Map<String, dynamic>?) ?? const {'name': 'Cliente'},
      ),
      reason: json['reason'] as String? ?? '',
      requestedBy: UserInfo.fromJson(
        json['requestedBy'] as Map<String, dynamic>,
      ),
      status: ReceiptCancellationRequestStatus.fromApi(json['status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num).toInt(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num).toInt())
          : null,
      reviewedBy: json['reviewedBy'] != null
          ? UserInfo.fromJson(json['reviewedBy'] as Map<String, dynamic>)
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['reviewedAt'] as num).toInt())
          : null,
      reviewNotes: json['reviewNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'docNumber': docNumber,
    'branchId': branchId,
    'receiptId': receiptId,
    'receiptDocNumber': receiptDocNumber,
    'receiptTotal': receiptTotal,
    'receiptPaymentMethod': receiptPaymentMethod.name,
    if (receiptShiftId != null) 'receiptShiftId': receiptShiftId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
    'reason': reason,
    'requestedBy': requestedBy.toJson(),
    'status': status.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
    if (reviewedBy != null) 'reviewedBy': reviewedBy!.toJson(),
    if (reviewedAt != null) 'reviewedAt': reviewedAt!.millisecondsSinceEpoch,
    if (reviewNotes != null) 'reviewNotes': reviewNotes,
  };
}
