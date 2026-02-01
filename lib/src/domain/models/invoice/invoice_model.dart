import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

enum InvoiceStatus { draft, open, paid, partiallypaid, cancelled }

class BaseInvoice {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final InvoiceStatus status;
  final PaymentType paymentType;
  final String bankReference;
  final int totalCost;
  final int total;
  final DateTime? paidAt;
  final UserInfo createdBy;

  BaseInvoice({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    required this.docNumber,
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.bankReference,
    required this.totalCost,
    required this.total,
    this.paidAt,
    required this.createdBy,
  });

  int get totalRemaining => total - amountPaid;

  factory BaseInvoice.fromJson(Map<String, dynamic> json) => BaseInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    totalCost: json['totalCost'],
    total: json['total'],
    paidAt: json['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['paidAt']) : null,
    createdBy: UserInfo.fromJson(json['createdBy']),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
    'docNumber': docNumber,
    'saleItems': saleItems.map((e) => e.toJson()).toList(),
    'description': description,
    'amountPaid': amountPaid,
    'status': status.name,
    'paymentType': paymentType.name,
    'bankReference': bankReference,
    'totalCost': totalCost,
    'total': total,
    'paidAt': paidAt?.millisecondsSinceEpoch,
    'createdBy': createdBy.toJson(),
  };
}

class CreateInvoice extends BaseInvoice {
  CreateInvoice({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.bankReference,
    required super.totalCost,
    required super.total,
    required super.createdBy,
  });

  factory CreateInvoice.fromJson(Map<String, dynamic> json) => CreateInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
  );

  CreateInvoice copyWithPaymentMethod(PaymentType paymentType, String? bankReference) {
    return CreateInvoice(
      branchId: branchId,
      clientId: clientId,
      clientInfo: clientInfo,
      docNumber: docNumber,
      saleItems: saleItems,
      description: description,
      amountPaid: amountPaid,
      status: status,
      paymentType: paymentType,
      bankReference: bankReference ?? "",
      totalCost: totalCost,
      total: total,
      createdBy: createdBy,
    );
  }
}

class UpdateInvoice {
  final int? ammountPaid;
  final InvoiceStatus? status;

  UpdateInvoice({this.ammountPaid, this.status});

  Map<String, dynamic> toJson() {
    final data = {
      'ammountPaid': ammountPaid,
      'status': status?.name,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class InvoiceInDb extends BaseInvoice {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InvoiceInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.bankReference,
    required super.totalCost,
    required super.total,
    required this.createdAt,
    this.updatedAt,
    super.paidAt,
    required super.createdBy,
  });

  factory InvoiceInDb.fromJson(Map<String, dynamic> json) => InvoiceInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    totalCost: json['totalCost'],
    total: json['total'],
    paidAt: json['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['paidAt']) : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
    createdBy: UserInfo.fromJson(json['createdBy']),
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
