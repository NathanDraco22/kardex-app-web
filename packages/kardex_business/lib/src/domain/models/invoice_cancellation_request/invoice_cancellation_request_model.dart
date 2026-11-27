import 'package:kardex_business/src/domain/models/common/client_info.dart';
import 'package:kardex_business/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/invoice/invoice_model.dart';

enum InvoiceCancellationRequestStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get display => switch (this) {
    InvoiceCancellationRequestStatus.pending => 'Pendiente',
    InvoiceCancellationRequestStatus.approved => 'Aprobada',
    InvoiceCancellationRequestStatus.rejected => 'Rechazada',
    InvoiceCancellationRequestStatus.cancelled => 'Cancelada',
  };

  static InvoiceCancellationRequestStatus fromApi(String? value) {
    return InvoiceCancellationRequestStatus.values.firstWhere(
      (e) => e.name == value?.toLowerCase(),
      orElse: () => InvoiceCancellationRequestStatus.pending,
    );
  }
}

class CreateInvoiceCancellationRequest {
  final String invoiceId;
  final String reason;
  final UserInfo requestedBy;

  const CreateInvoiceCancellationRequest({
    required this.invoiceId,
    required this.reason,
    required this.requestedBy,
  });

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'reason': reason,
    'requestedBy': requestedBy.toJson(),
  };
}

class InvoiceCancellationRequestInDb {
  final String id;
  final String docNumber;
  final String branchId;
  final String invoiceId;
  final String invoiceDocNumber;
  final int invoiceTotal;
  final PaymentType invoicePaymentType;
  final InvoiceStatus invoiceStatus;
  final String? invoiceShiftId;
  final String clientId;
  final ClientInfo clientInfo;
  final String reason;
  final UserInfo requestedBy;
  final InvoiceCancellationRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserInfo? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  const InvoiceCancellationRequestInDb({
    required this.id,
    required this.docNumber,
    required this.branchId,
    required this.invoiceId,
    required this.invoiceDocNumber,
    required this.invoiceTotal,
    required this.invoicePaymentType,
    required this.invoiceStatus,
    this.invoiceShiftId,
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

  factory InvoiceCancellationRequestInDb.fromJson(Map<String, dynamic> json) {
    return InvoiceCancellationRequestInDb(
      id: json['id'] as String,
      docNumber: json['docNumber'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      invoiceId: json['invoiceId'] as String? ?? '',
      invoiceDocNumber: json['invoiceDocNumber'] as String? ?? '',
      invoiceTotal: (json['invoiceTotal'] as num?)?.toInt() ?? 0,
      invoicePaymentType: PaymentType.values.byName(
        (json['invoicePaymentType'] ?? 'cash').toString().toLowerCase(),
      ),
      invoiceStatus: InvoiceStatus.values.byName(
        (json['invoiceStatus'] ?? 'paid').toString().toLowerCase(),
      ),
      invoiceShiftId: json['invoiceShiftId'] as String?,
      clientId: json['clientId'] as String? ?? '',
      clientInfo: ClientInfo.fromJson(
        (json['clientInfo'] as Map<String, dynamic>?) ?? const {'name': 'Cliente'},
      ),
      reason: json['reason'] as String? ?? '',
      requestedBy: UserInfo.fromJson(
        json['requestedBy'] as Map<String, dynamic>,
      ),
      status: InvoiceCancellationRequestStatus.fromApi(json['status'] as String?),
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
    'invoiceId': invoiceId,
    'invoiceDocNumber': invoiceDocNumber,
    'invoiceTotal': invoiceTotal,
    'invoicePaymentType': invoicePaymentType.name,
    'invoiceStatus': invoiceStatus.name,
    if (invoiceShiftId != null) 'invoiceShiftId': invoiceShiftId,
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
