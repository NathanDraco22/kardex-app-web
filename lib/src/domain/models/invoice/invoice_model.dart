import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';

enum InvoiceStatus { open, paid, parciallyPaid, cancelled }

// --- Modelos Principales de Factura ---
class BaseInvoice {
  final String branchId;
  final String clientId;
  final String docNumber;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final InvoiceStatus status;
  final PaymentType paymentType;
  final int totalCost;
  final int total;

  BaseInvoice({
    required this.branchId,
    required this.clientId,
    required this.docNumber,
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.totalCost,
    required this.total,
  });

  factory BaseInvoice.fromJson(Map<String, dynamic> json) => BaseInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'docNumber': docNumber,
    'saleItems': saleItems.map((e) => e.toJson()).toList(),
    'description': description,
    'amountPaid': amountPaid,
    'status': status.name,
    'paymentType': paymentType.name,
    'totalCost': totalCost,
    'total': total,
  };
}

class CreateInvoice extends BaseInvoice {
  CreateInvoice({
    required super.branchId,
    required super.clientId,
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
  });

  factory CreateInvoice.fromJson(Map<String, dynamic> json) => CreateInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
  );
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
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
    required this.createdAt,
    this.updatedAt,
  });

  factory InvoiceInDb.fromJson(Map<String, dynamic> json) => InvoiceInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
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
