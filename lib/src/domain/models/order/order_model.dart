import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

enum OrderStatus {
  draft("Borrador"),
  open("Abierto"),
  completed("Completado"),
  cancelled("Cancelado");

  const OrderStatus(this.tag);
  final String tag;
}

class BaseOrder {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final String invoiceId;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final OrderStatus status;
  final PaymentType paymentType;
  final int totalCost;
  final int total;
  final UserInfo createdBy;

  BaseOrder({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    this.docNumber = "",
    this.invoiceId = "",
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.totalCost,
    required this.total,
    required this.createdBy,
  });

  factory BaseOrder.fromJson(Map<String, dynamic> json) => BaseOrder(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    invoiceId: json['invoiceId'] ?? "",
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: OrderStatus.values.byName(json['status']),
    paymentType: PaymentType.values.byName(json['paymentType']),
    totalCost: json['totalCost'],
    total: json['total'],
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
    'totalCost': totalCost,
    'total': total,
    'createdBy': createdBy.toJson(),
  };
}

class CreateOrder extends BaseOrder {
  CreateOrder({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
    required super.createdBy,
  });

  factory CreateOrder.fromJson(Map<String, dynamic> json) => CreateOrder(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: OrderStatus.values.byName(json['status']),
    paymentType: PaymentType.values.byName(json['paymentType']),
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
  );
}

class UpdateOrder {
  final OrderStatus? status;
  final List<SaleItem>? saleItems;
  final String? description;
  final PaymentType? paymentType;
  final int? totalCost;
  final int? total;

  UpdateOrder({
    this.status,
    this.saleItems,
    this.description,
    this.paymentType,
    this.totalCost,
    this.total,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'status': status?.name,
      'saleItems': saleItems?.map((e) => e.toJson()).toList(),
      'description': description,
      'paymentType': paymentType?.name,
      'totalCost': totalCost,
      'total': total,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class OrderInDb extends BaseOrder {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.clientInfo, // Campo añadido
    super.docNumber,
    super.invoiceId,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
    required this.createdAt,
    this.updatedAt,
    required super.createdBy,
  });

  factory OrderInDb.fromJson(Map<String, dynamic> json) => OrderInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']), // Campo añadido
    docNumber: json['docNumber'] ?? "",
    invoiceId: json['invoiceId'] ?? "",
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: OrderStatus.values.byName(json['status']),
    paymentType: PaymentType.values.byName(json['paymentType']),
    totalCost: json['totalCost'],
    total: json['total'],
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
