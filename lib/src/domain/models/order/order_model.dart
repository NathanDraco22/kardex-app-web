import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';

enum OrderStatus { open, completed, cancelled }

class ClientInfo {
  final String name;

  ClientInfo({required this.name});

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(name: json['name']);

  Map<String, dynamic> toJson() => {'name': name};
}

class BaseOrder {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final OrderStatus status;
  final PaymentType paymentType;
  final int totalCost;
  final int total;

  BaseOrder({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    this.docNumber = "",
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.totalCost,
    required this.total,
  });

  factory BaseOrder.fromJson(Map<String, dynamic> json) => BaseOrder(
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
  );
}

class UpdateOrder {
  final OrderStatus? status;

  UpdateOrder({this.status});

  Map<String, dynamic> toJson() {
    final data = {
      'status': status?.name,
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

  factory OrderInDb.fromJson(Map<String, dynamic> json) => OrderInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']), // Campo añadido
    docNumber: json['docNumber'] ?? "",
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: OrderStatus.values.byName(json['status']),
    paymentType: PaymentType.values.byName(json['paymentType']),
    totalCost: json['totalCost'],
    total: json['total'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
