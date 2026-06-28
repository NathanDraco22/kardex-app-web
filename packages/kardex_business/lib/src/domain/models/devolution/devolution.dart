import '../common/client_info.dart';
import '../common/sale_item_model.dart';
import '../common/user_info.dart';

enum DevolutionStatus { open, confirmed, cancelled, applied }

class BaseDevolution {
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final String originalInvoiceId;
  final String originalInvoiceDocNumber;
  final List<SaleItem> returnedItems;
  final String description;
  final DevolutionStatus status;
  final int totalCost;
  final int total;
  final UserInfo createdBy;

  BaseDevolution({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    this.docNumber = "",
    required this.originalInvoiceId,
    required this.originalInvoiceDocNumber,
    required this.returnedItems,
    required this.description,
    this.status = DevolutionStatus.open,
    required this.totalCost,
    required this.total,
    required this.createdBy,
  });

  factory BaseDevolution.fromJson(Map<String, dynamic> json) => BaseDevolution(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    originalInvoiceId: json['originalInvoiceId'] ?? "",
    originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
    returnedItems: (json['returnedItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'],
    status: DevolutionStatus.values.byName(json['status']),
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
    'docNumber': docNumber,
    'originalInvoiceId': originalInvoiceId,
    'originalInvoiceDocNumber': originalInvoiceDocNumber,
    'returnedItems': returnedItems.map((e) => e.toJson()).toList(),
    'description': description,
    'status': status.name,
    'totalCost': totalCost,
    'total': total,
    'createdBy': createdBy.toJson(),
  };
}

class CreateDevolution extends BaseDevolution {
  CreateDevolution({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    super.docNumber,
    required super.originalInvoiceId,
    required super.originalInvoiceDocNumber,
    required super.returnedItems,
    required super.description,
    super.status,
    required super.totalCost,
    required super.total,
    required super.createdBy,
  });

  factory CreateDevolution.fromJson(Map<String, dynamic> json) => CreateDevolution(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    originalInvoiceId: json['originalInvoiceId'] ?? "",
    originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
    returnedItems: (json['returnedItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'],
    status: DevolutionStatus.values.byName(json['status']),
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
  );
}

class UpdateDevolution {
  final DevolutionStatus? status;

  UpdateDevolution({this.status});

  Map<String, dynamic> toJson() {
    final data = {'status': status?.name};
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class DevolutionInDb extends BaseDevolution {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DevolutionInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    super.docNumber,
    required super.originalInvoiceId,
    required super.originalInvoiceDocNumber,
    required super.returnedItems,
    required super.description,
    super.status,
    required super.totalCost,
    required super.total,
    required super.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory DevolutionInDb.fromJson(Map<String, dynamic> json) => DevolutionInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    originalInvoiceId: json['originalInvoiceId'] ?? "",
    originalInvoiceDocNumber: json['originalInvoiceDocNumber'] ?? "",
    returnedItems: (json['returnedItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'],
    status: DevolutionStatus.values.byName(json['status']),
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
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
